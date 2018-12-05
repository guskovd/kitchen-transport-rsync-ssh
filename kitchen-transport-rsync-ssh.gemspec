$:.push File.expand_path('../lib', __FILE__)

require 'kitchen/transport/rsync_ssh_version.rb'

Gem::Specification.new do |spec|
  spec.name = 'kitchen-transport-rsync-ssh'
  spec.version = Kitchen::Transport::RSYNC_SSH_VERSION
  spec.authors = 'Danil Guskov'
  spec.email = 'guskovd86@mail.ru'
  spec.description = 'Additional Test kitchen transport using rsync and ssh'
  spec.summary = spec.description
  spec.license = 'Apache 2'

  spec.files = `git ls-files`.split($/)
  spec.executables = []
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'test-kitchen'
end
