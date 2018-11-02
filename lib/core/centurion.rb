module Centurion
  def self.vm(opts)
    provider = Centurion.configuration.provider
    template = Centurion.configuration.find_template(opts[:template])

    Centurion::VM.new({
      name: File.basename(opts[:path]),
      path: opts[:path],
      ips: [],
      status: :provisioning,
      adapter: template.adapter,
      provider: provider
    }).tap do |vm|
      Thread.new do
        begin
          ips = provider.create(
            template.path,
            vm.path
          )
          vm.ips = ips
          vm.status = VM::Status::READY
        rescue StandardError => se
          vm.status = VM::Status::FAILED
          vm.errors << se
        end
      end
    end
  end

  def self.vms(opts)
    Centurion::Pool.new.tap do |pool|
      opts.delete(:pool_size).times do |i|
        path = opts[:path]
        path += "_#{i}"
        pool.vms << vm(
          template: opts[:template],
          path: path
        )
      end
    end
  end
end
