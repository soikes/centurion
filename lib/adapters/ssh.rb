require 'net/ssh'
require 'net/scp'

module Centurion
  module Error
    class NoIPsAccessibleError < StandardError; end
  end
  module Adapter
    class SSH
      def initialize(opts)
        @username = opts[:username]
        @password = opts[:password]
      end

      def run(ips, command)
        try_with_ips(ips) { |ip| ssh(ip, command) }
      end

      def upload(ips, local_path, remote_path)
        try_with_ips(ips) do |ip|
          Net::SCP.upload!(
            ip,
            @username,
            local_path,
            remote_path,
            ssh: { password: @password }
          )
        end
      end

      def download(ips, remote_path, local_path)
        try_with_ips(ips) do |ip|
          Net::SCP.download!(
            ip,
            @username,
            remote_path,
            local_path,
            ssh: { password: @password }
          )
        end
      end

      private

      def try_with_ips(ips, &block)
        return nil if ips.empty?
        failures = {}
        ips.each do |ip|
          begin
            return yield ip
          rescue Net::SSH::ConnectionTimeout, Timeout::Error, SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
            failures.merge!({ip => e.class})
          end
        end
        raise Centurion::Error::NoIPsAccessibleError, failures
      end

      def ssh(ip, command)
        stdout = ''
        stderr = ''
        Net::SSH.start(ip, @username, password: @password, timeout: 5) do |ssh|
          ssh.exec!(command) do |channel, stream, data|
            stdout << data if stream == :stdout
            stderr << data if stream == :stderr
            Centurion.logger.warn "stderr: #{stderr}" if !stderr.empty?
          end
        end
        stdout.chomp
      end
    end
  end
end
