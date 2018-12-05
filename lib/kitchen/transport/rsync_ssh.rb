require 'kitchen/transport/ssh'
# rubocop:disable Metrics/LineLength, Metrics/AbcSize, Metrics/MethodLength

module Kitchen
  module Transport
    # RsyncSsh - combined Rsync & Ssh transport
    class RsyncSsh < Ssh
      def create_new_connection(options, &block)
        if @connection
          logger.debug("[RsyncSsh] shutting previous connection #{@connection}")
          @connection.close
        end
        @connection_options = options
        @connection = Kitchen::Transport::RsyncSsh::Connection.new(options, &block)
      end
      # Connection
      class Connection < Ssh::Connection
        def login_command
          args  = %W{ -p #{options[:password]}}
          args += %w{ ssh }
          args += %w{ -o UserKnownHostsFile=/dev/null }
          args += %w{ -o StrictHostKeyChecking=no }
          args += %w{ -o IdentitiesOnly=yes } if options[:keys]
          args += %W{ -o LogLevel=#{logger.debug? ? 'VERBOSE' : 'ERROR'} }
          if options.key?(:forward_agent)
            args += %W{ -o ForwardAgent=#{options[:forward_agent] ? 'yes' : 'no'} }
          end
          if ssh_gateway
            gateway_command = "ssh -q #{ssh_gateway_username}@#{ssh_gateway} nc #{hostname} #{port}"
            # Should support other ports than 22 for ssh gateways
            args += %W{ -o ProxyCommand=#{gateway_command} -p 22 }
          end
          Array(options[:keys]).each { |ssh_key| args += %W{ -i #{ssh_key} } }
          args += %W{ -p #{port} }
          args += %W{ #{username}@#{hostname} }

          l = LoginCommand.new("sshpass", args)
        end

        def upload(locals, remote)
          # unless File.exist?('/usr/bin/rsync')
          #   logger.debug('[rsync] Rsync already failed or not installed, not trying it')
          #   return super
          # end
          locals = Array(locals)
          rsync_candidates = locals.select { |path| File.exist?(path) && File.basename(path) != 'cache' }
          rsync_cmd = "/usr/bin/env rsync -Lqrazc #{rsync_candidates.join(' ')} rsync://#{session.host}/#{remote}"
          time = Benchmark.realtime do
            system(rsync_cmd)
          end
          logger.info("[rsync] Time taken to upload: %.2f sec" % time)
        end
      end
    end
  end
end
