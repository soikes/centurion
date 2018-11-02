require 'benchmark'
require 'ipaddr'
require 'rbvmomi'
require 'timeout'

module Centurion
  module Error
    class NoIPError < StandardError; end
  end

  module Provider
    class VSphere
      def initialize(opts)
        @dc = connect(opts[:hostname], opts[:username], opts[:password])
          .serviceInstance
          .find_datacenter
      end

      def create(source_path, dest_path)
        ips_of(find_vm(dest_path) || clone(source_path, dest_path))
      end

      def destroy(path)
        vm = find_vm(path)
        vm.PowerOffVM_Task.wait_for_completion if vm.runtime.powerState == 'poweredOn'
        vm.Destroy_Task.wait_for_completion
      end

      private

      def connect(hostname, username, password)
        RbVmomi::VIM.connect(
          host: hostname,
          user: username,
          password: password,
          insecure: true
        )
      end

      def find_vm(path)
        @dc.find_vm(path)
      end

      def find_folder(path)
        @dc.find_folder(path)
      end

      def clone(source_path, dest_path)
        source_vm = find_vm(source_path)
        source_vm.CloneVM_Task(
          folder: find_folder(File.dirname(dest_path)),
          name: File.basename(dest_path),
          spec: RbVmomi::VIM.VirtualMachineCloneSpec(
            location: RbVmomi::VIM.VirtualMachineRelocateSpec(
              diskMoveType: :createNewChildDiskBacking
            ),
            powerOn: true,
            template: false,
            snapshot: source_vm.snapshot.currentSnapshot
          )
        ).wait_for_completion
        find_vm(dest_path)
      end

      def ips_of(vm)
        Timeout.timeout(300) { sleep 2 while vm.guest.net.empty? || !vm.guest.ipAddress }
        vm.guest.net.first.ipAddress.select do |ip|
          ip_addr = IPAddr.new(ip)
          !ip_addr.link_local? && (ip_addr.ipv4? || ip_addr.ipv6?)
        end
      rescue Timeout::Error
        raise Centurion::Error::NoIPError, 'no ips detected after 300 seconds'
      end
    end
  end
end
