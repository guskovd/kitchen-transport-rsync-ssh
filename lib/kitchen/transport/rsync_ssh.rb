# rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/LineLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

require 'kitchen/transport/ssh'

module Kitchen
  # module Transport
  module Transport
    # RsyncSsh - combined Rsync & Ssh transport
    class RsyncSsh < Ssh
      default_config :protocol, 'ssh'
      def connection_options(data)
        opts = super
        opts[:protocol] = data[:protocol]
        opts
      end

      def create_new_connection(options, &block)
        if @connection
          logger.debug("[RsyncSsh] shutting previous connection #{@connection}")
          @connection.close
        end
        @connection_options = options
        Kitchen::Transport::RsyncSsh::Connection.new(options, &block)
      end

      # Connection
      class Connection < Ssh::Connection
        def init_options(options)
          super
          @protocol = @options.delete(:protocol)
        end

        def login_command
          # login comman overwrite.
          if options[:password]
            command = 'sshpass'
            args  = %W[-p #{options[:password]}]
            args += %w[ssh]
          else
            command = 'ssh'
            args = []
          end
          args += %w[-o UserKnownHostsFile=/dev/null]
          args += %w[-o StrictHostKeyChecking=no]
          args += %w[-o IdentitiesOnly=yes] if options[:keys]
          args += %W[-o LogLevel=#{logger.debug? ? 'VERBOSE' : 'ERROR'}]
          if options.key?(:forward_agent)
            args += %W[-o ForwardAgent=#{options[:forward_agent] ? 'yes' : 'no'}]
          end
          if ssh_gateway
            gateway_command = "ssh -q #{ssh_gateway_username}@#{ssh_gateway} nc #{hostname} #{port}"
            # Should support other ports than 22 for ssh gateways
            args += %W[-o ProxyCommand=#{gateway_command} -p 22]
          end
          Array(options[:keys]).each { |ssh_key| args += %W[-i #{ssh_key}] }
          args += %W[-p #{port}]
          args += %W[#{username}@#{hostname}]

          logger.debug("Starting command: #{args} with args: #{args}")

          LoginCommand.new(command, args)
        end

        def upload(locals, remote)
          locals = Array(locals)
          rsync_candidates = locals.select { |path| File.exist?(path) && File.basename(path) != 'cache' }

          if @protocol == 'rsync'
            rsync_cmd = "rsync -Lqrazc #{rsync_candidates.join(' ')} rsync://#{session.host}/#{remote}"
          else
            ssh_command = "ssh #{ssh_args.join(' ')}"
            rsync_cmd = "rsync -e '#{ssh_command}' -az#{logger.level == :debug ? 'vv' : ''} --delete #{rsync_candidates.join(' ')} #{username}@#{session.host}:#{remote}"
          end
          time = Benchmark.realtime do
            system(rsync_cmd)
          end
          logger.info('[rsync] Time taken to upload: %.2f sec' % time) # rubocop:disable Style/FormatString
        end

        def ssh_args
          args = %w[-o UserKnownHostsFile=/dev/null]
          args += %w[-o StrictHostKeyChecking=no]
          args += %w[-o IdentitiesOnly=yes] if options[:keys]
          args += %W[-o LogLevel=#{@logger.debug? ? 'VERBOSE' : 'ERROR'}]
          args += %W[-o ForwardAgent=#{options[:forward_agent] ? 'yes' : 'no'}] if options.key? :forward_agent
          Array(options[:keys]).each { |ssh_key| args += %W[-i #{ssh_key}] }
          args += %W[-p #{options[:port]}]
        end
      end
    end
  end
end
