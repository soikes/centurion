require 'active_support/core_ext/module/attribute_accessors'
require 'yaml'
require_relative '../adapters/ssh'
require_relative '../providers/vsphere'
require_relative 'template'

module Centurion
  mattr_accessor :configuration

  class Configuration
    attr_accessor :provider
    attr_accessor :templates

    def initialize
      @provider = nil
      @templates ||= []
    end

    def use_provider(name, opts)
      provider =
      case name
      when :vsphere
        Centurion::Provider::VSphere
      end
      @provider = provider.send(:new, opts)
    end

    def add_template(name, opts)
      adapter =
      case opts[:adapter]
      when :ssh
        Centurion::Adapter::SSH
      end
      @templates << Centurion::Template.new(name, opts[:path], adapter.send(:new, opts))
    end

    def find_template(name)
      @templates.find { |p| p.name == name }
    end
  end

  def self.configure
    Centurion.configuration ||= Centurion::Configuration.new.tap { |config| yield config }
  end
end
