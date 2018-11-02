module Centurion
  class Pool
    include Enumerable

    attr_accessor :vms

    def initialize
      @vms = []
    end

    def each(&block)
      @vms.each { |vm| block.call(vm) }
    end

    FORWARDED_COLLECTION_METHODS = [:name, :path, :ips, :status, :destroy]
    FORWARDED_COLLECTION_METHODS.each do |method|
      define_method(method) do
        @vms.map(&method)
      end
    end

    FORWARDED_STATUS_CHECKS = [:ready?, :destroyed?]
    FORWARDED_STATUS_CHECKS.each do |method|
      define_method(method) do
        @vms.map(&method).all?{ |status| true & status }
      end
    end

    def run(command)
      @vms.map { |vm| vm.run(command) }.map(&:value)
    end

    def upload(local_path, remote_path)
      @vms.map { |vm| vm.upload(local_path, remote_path) }.map(&:value)
    end

    def download(remote_path, local_path)
      @vms.map { |vm| vm.download(remote_path, local_path) }.map(&:value)
    end
  end
end
