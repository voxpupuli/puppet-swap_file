# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:swap_file).provider(:linux) do
  let(:resource) do
    Puppet::Type.type(:swap_file).new(
      {
        name: '/mnt/swap',
        size: '1024',
        provider: described_class.name
      }
    )
  end

  let(:provider) { resource.provider }

  let(:instance) { provider.class.instances.first }

  swapon_s_output = <<~EOS
    Filename                        Type            Size    Used    Priority
    /dev/sda2                       partition       4192956 0       -1
    /dev/sda1                       partition       4454542 0       -2
  EOS

  swapon_line = <<~EOS
    /dev/sda2                       partition       4192956 0       -1
  EOS

  mkswap_return = <<~EOS
    Setting up swapspace version 1, size = 524284 KiB
    no label, UUID=0e5e7c60-bbba-4089-a76c-2bb29c0f0839
  EOS

  swapon_line_to_hash = {
    ensure: :present,
    file: '/dev/sda2',
    name: '/dev/sda2',
    priority: '-1',
    provider: :swap_file,
    size: '4192956',
    type: 'partition',
    used: '0',
  }

  before do
    allow(Facter).to receive(:value).with(:kernel).and_return('Linux')
    allow(provider.class).to receive(:swapon).with(['-s']).and_return(swapon_s_output)
  end

  describe 'self.prefetch' do
    it 'exists' do
      provider.class.instances
      provider.class.prefetch({})
    end
  end

  describe 'exists?' do
    it 'checks if swap file exists' do
      expect(instance).to exist
    end
  end

  describe 'self.instances' do
    it 'returns an array of swapfiles' do
      swapfiles      = provider.class.instances.map(&:name)
      swapfile_sizes = provider.class.instances.map(&:size)

      expect(swapfiles).to      include('/dev/sda1', '/dev/sda2')
      expect(swapfile_sizes).to include('4192956', '4454542')
    end
  end

  describe 'self.get_swapfile_properties' do
    it 'turns results from swapon -s line to hash' do
      swapon_line_to_hash_provider = provider.class.get_swapfile_properties(swapon_line)
      expect(swapon_line_to_hash_provider).to eql swapon_line_to_hash
    end
  end

  describe 'create_swap_file' do
    it 'runs mkswap and swapon' do
      allow(provider).to receive(:mkswap).and_return(mkswap_return)
      allow(provider).to receive(:swapon).and_return('')
      provider.create_swap_file('/mnt/swap')
    end
  end

  describe 'swap_off' do
    it 'runs swapoff and returns the log of the command' do
      allow(provider).to receive(:swapoff).and_return('')
      provider.swap_off('/mnt/swap')
    end
  end
end
