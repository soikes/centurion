module Centurion
  class VM
    attr_reader :name
    attr_reader :path
    attr_accessor :ips
    attr_accessor :status
    attr_accessor :errors

    module Status
      PROVISIONING = :provisioning
      READY = :ready
      FAILED = :failed
      DESTROYED = :destroyed
    end

    def initialize(opts)
      @name = opts[:name]
      @path = opts[:path]
      @ips = opts[:ips]
      @status = Status::PROVISIONING
      @adapter = opts[:adapter]
      @provider = opts[:provider]
      @errors = []
    end

    def run(command)
      Thread.new do
        @adapter.run(@ips, command)
      end
    end

    def upload(local_path, remote_path)
      Thread.new do
        @adapter.upload(@ips, local_path, remote_path)
      end
    end

    def download(remote_path, local_path)
      Thread.new do
        @adapter.download(@ips, remote_path, local_path)
      end
    end

    def destroy
      Thread.new do
        @provider.destroy(@path)
        @status = Status::DESTROYED
      end
    end

    Status.constants.each do |constant|
      status = Status.const_get(constant)
      define_method("#{status}?".to_sym) do
        @status == status
      end
    end
  end
end
