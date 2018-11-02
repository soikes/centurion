require 'logger'
require 'centurion/version'

require 'adapters/ssh'

require 'core/centurion'
require 'core/configuration'
require 'core/pool'
require 'core/vm'

require 'providers/vsphere'


module Centurion
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.level = Logger::WARN
        log.progname = self.name
      end
    end
  end
end
