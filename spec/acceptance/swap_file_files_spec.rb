# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'swap_file::files' do
  after(:context) do
    pp = <<-EOS
      swap_file::files { 'default':
        ensure   => absent,
      }
      swap_file::files { 'tmp file swap':
        ensure   => absent,
        swapfile => '/tmp/swapfile',
      }
      swap_file::files { 'tmp file swap 1':
        ensure   => absent,
        swapfile => '/tmp/swapfile1',
      }
      swap_file::files { 'tmp file swap 2':
        ensure   => absent,
        swapfile => '/tmp/swapfile2',
      }
    EOS

    apply_manifest(pp, catch_failures: true)
  end

  context 'with default parameter' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          swap_file::files { 'default':
            ensure   => present,
          }
        PUPPET
      end
    end

    describe file('/etc/fstab'), shell('/sbin/swapon -s') do
      its(:content) { is_expected.to match %r{/mnt/swap.1} }
    end
  end

  context 'with custom swapfile' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          swap_file::files { 'tmp file swap':
            ensure       => present,
            swapfile     => '/tmp/swapfile',
            swapfilesize => '100MB'
          }
        PUPPET
      end
    end

    describe file('/etc/fstab'), shell('/sbin/swapon -s') do
      its(:content) { is_expected.to match %r{/tmp/swapfile} }
    end
  end

  context 'with multiple resource' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          swap_file::files { 'tmp file swap 1':
            ensure       => present,
            swapfile     => '/tmp/swapfile1',
            swapfilesize => '100MB'
          }

          swap_file::files { 'tmp file swap 2':
            ensure       => present,
            swapfile     => '/tmp/swapfile2',
            swapfilesize => '100MB'
          }
        PUPPET
      end
    end

    describe file('/etc/fstab'), shell('/sbin/swapon -s') do
      its(:content) { is_expected.to match %r{/tmp/swapfile1} }
      its(:content) { is_expected.to match %r{/tmp/swapfile2} }
    end
  end

  context 'with fallocate command' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        swap_file::files { 'default':
          ensure       => present,
          cmd          => 'fallocate',
          swapfilesize => '100MB'
        }
        PUPPET
      end
    end

    describe file('/etc/fstab'), shell('/sbin/swapon -s') do
      its(:content) { is_expected.to match %r{/mnt/swap.1} }
    end
  end
end
