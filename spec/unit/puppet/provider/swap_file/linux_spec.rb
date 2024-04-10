# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:swap_file).provider(:linux) do
  let(:params) do
    {
      name: '/tmp/swap',
      size: '1024',
      provider: described_class.name
    }
  end
  let(:type_class) { Puppet::Type.type(:swap_file).provider(:linux) }
  let(:resource) { Puppet::Type.type(:swap_file).new(params) }
  let(:provider) { resource.provider }
  let(:instances) { type_class.instances }

  describe 'self.prefetch' do
    it 'exists' do
      expect(type_class).to respond_to :prefetch
    end
  end

  describe 'exists?' do
    it 'checks if swap file exists' do
      allow(type_class).to receive(:swapon).with(['-s']).and_return <<~EOS
        Filename                        Type            Size    Used    Priority
        /dev/sda2                       partition       4192956 0       -1
      EOS
      expect(instances.first).to exist
    end
  end

  describe 'self.instances' do
    it 'exists' do
      allow(type_class).to receive(:swapon).with(['-s']).and_return <<~EOS
        Filename                        Type            Size    Used    Priority
        /dev/sda2                       partition       4192956 0       -1
      EOS
      expect(type_class).to respond_to :instances
    end

    it 'returns an array of swapfiles' do
      allow(type_class).to receive(:swapon).with(['-s']).and_return <<~EOS
        Filename                        Type            Size    Used    Priority
        /dev/sda2                       partition       4192956 0       -1
        /dev/sda1                       partition       4454542 0       -2
      EOS
      expect(instances.map do |prov|
        {
          name: prov.get(:name),
          size: prov.get(:size)
        }
      end).to eq(
        [
          {
            name: '/dev/sda1',
            size: '4454542'
          },
          {
            name: '/dev/sda2',
            size: '4192956'
          }
        ]
      )
    end
  end

  describe 'self.get_swapfile_properties' do
    it 'turns results from swapon -s line to hash' do
      allow(type_class).to receive(:swapon).with(['-s']).and_return <<~EOS
        Filename                        Type            Size    Used    Priority
        /dev/sda2                       partition       4192956 0       -1
      EOS
      allow(provider).to receive(:get_swapfile_properties).and_return <<~EOS
        /dev/sda2                       partition       4192956 0       -1
      EOS
      expect(instances.map do |prov|
        {
          ensure: prov.get(:ensure),
          file: prov.get(:file),
          name: prov.get(:name),
          priority: prov.get(:priority),
          provider: prov.get(:provider),
          size: prov.get(:size),
          type: prov.get(:type),
          used: prov.get(:used)
        }
      end).to eq([{
                   ensure: :present,
                   file: '/dev/sda2',
                   name: '/dev/sda2',
                   priority: '-1',
                   provider: :swap_file,
                   size: '4192956',
                   type: 'partition',
                   used: '0',
                 }])
    end
  end

  describe 'create_swap_file' do
    it 'runs mkswap and swapon' do
      allow(type_class).to receive(:mkswap).and_return <<~EOS
        Setting up swapspace version 1, size = 524284 KiB
        no label, UUID=0e5e7c60-bbba-4089-a76c-2bb29c0f0839
      EOS
      allow(type_class).to receive(:swapon).and_return('')
      # expect(provider.create_swap_file('/tmp/swap')).to be_nil
      provider.create_swap_file('/tmp/swap')
    end
  end

  describe 'swap_off' do
    it 'runs swapoff and returns the log of the command' do
      allow(type_class).to receive(:swapoff).and_return('')
      # expect(instances.first.swap_off).to eq('/tmp/swap')
      provider.swap_off('/tmp/swap')
    end
  end
end
