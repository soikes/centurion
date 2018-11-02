require 'spec_helper'

RSpec.describe Centurion::Adapter::SSH do
  subject { Centurion::Adapter::SSH.new(username: username, password: password) }

  let(:username) { 'user' }
  let(:password) { 'password' }
  let(:ipv4) { Faker::Internet.ip_v4_address }
  let(:ipv6) { Faker::Internet.ip_v6_address }

  describe '#run' do
    it 'calls #ssh with an ip and command' do
      command = 'ls C:/'
      expect(subject).to receive(:ssh).with(ipv4, command)
      subject.run([ipv4], command)
    end
  end

  describe '#upload' do
    it 'calls upload with ip and paths' do
      local_path = 'local/path'
      remote_path = 'remote/path'
      expect(Net::SCP).to receive(:upload!).with(
        ipv4,
        username,
        local_path,
        remote_path,
        ssh: { password: password }
      )
      subject.upload([ipv4], local_path, remote_path)
    end
  end

  describe '#download' do
    it 'calls download with ip and paths' do
      local_path = 'local/path'
      remote_path = 'remote/path'
      expect(Net::SCP).to receive(:download!).with(
        ipv4,
        username,
        local_path,
        remote_path,
        ssh: { password: password }
      )
      subject.download([ipv4], local_path, remote_path)
    end
  end

  describe 'private methods' do
    before(:each) do
      Centurion::Adapter::SSH.send(:public, *Centurion::Adapter::SSH.private_instance_methods)
    end

    describe '#try_with_ips' do
      context 'using one ip address' do
        it 'executes the given block once' do
          expect { |b| subject.send(:try_with_ips, [ipv4], &b) }.to yield_control.exactly(1).times
          expect { |b| subject.send(:try_with_ips, [ipv4], &b) }.to yield_with_args(ipv4)
        end
      end

      context 'using no ip addresses' do
        it 'does not execute the given block' do
          expect { |b| subject.send(:try_with_ips, [], &b) }.to yield_control.exactly(0).times
        end
      end

      context 'using more than one ip address' do
        it 'executes the block for the first valid ip address only' do
          expect { |b| subject.try_with_ips([ipv4, ipv6], &b) }.to yield_control.exactly(1).times
          expect { |b| subject.try_with_ips([ipv4, ipv6], &b) }.to yield_with_args(ipv4)
        end
      end

      it 'rescues errors thrown by Net::SSH' do
        expect { subject.try_with_ips([ipv4]) { raise Net::SSH::ConnectionTimeout } }.to raise_error(Centurion::Error::NoIPsAccessibleError)
        expect { subject.try_with_ips([ipv4]) { raise Timeout::Error } }.to raise_error(Centurion::Error::NoIPsAccessibleError)
        expect { subject.try_with_ips([ipv4]) { raise SocketError } }.to raise_error(Centurion::Error::NoIPsAccessibleError)
        expect { subject.try_with_ips([ipv4]) { raise Errno::ECONNREFUSED } }.to raise_error(Centurion::Error::NoIPsAccessibleError)
        expect { subject.try_with_ips([ipv4]) { raise Errno::EHOSTUNREACH } }.to raise_error(Centurion::Error::NoIPsAccessibleError)
        expect { subject.try_with_ips([ipv4]) { raise 'other' } }.to raise_error
      end
    end

    describe '#ssh' do
      it 'calls start with ip and options' do
        command = 'ls C:/'
        expect(Net::SSH).to receive(:start).with(
          ipv4,
          username,
          password: password,
          timeout: 5
        )
        subject.ssh(ipv4, command)
      end
    end
  end
end
