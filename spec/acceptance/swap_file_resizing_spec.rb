# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'swap_file::files' do
  after(:all) do
    pp = <<-EOS
      swap_file::files { 'default':
        ensure   => absent,
      }
    EOS

    apply_manifest(pp, catch_failures: true)
  end

  context 'swapfilesize => 100' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        swap_file::files { 'default':
          ensure       => present,
          swapfilesize => '100MB',
          resize_existing => true,
        }
        PUPPET
      end
    end

    describe file('/etc/fstab'), shell('/sbin/swapon -s') do
      its(:content) { is_expected.to match %r{/mnt/swap.1} }
    end

    describe file('/proc/swaps') do
      its(:content) { is_expected.to match %r{102396} }
    end
  end

  context 'resize swap file' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        swap_file::files { 'default':
          ensure          => present,
          swapfilesize    => '200MB',
          resize_existing => true,
        }
        PUPPET
      end
    end

    describe file('/etc/fstab'), shell('/sbin/swapon -s') do
      its(:content) { is_expected.to match %r{/mnt/swap.1} }
    end

    describe file('/proc/swaps') do
      its(:content) { is_expected.to match %r{204796} }
    end
  end
end
