# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'swap_file class' do
  after(:all) do
    pp = <<-EOS
    class { 'swap_file':
      files => {
        'swapfile' => {
          ensure => 'absent',
        },
        'use fallocate' => {
          swapfile => '/tmp/swapfile.fallocate',
          cmd      => 'fallocate',
          ensure   => absent,
        },
        'remove swap file' => {
          ensure   => 'absent',
          swapfile => '/tmp/swapfile.old',
        },
      },
    }
    EOS

    apply_manifest(pp, catch_failures: true)
  end

  context 'with multiple files config' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'swap_file':
            files => {
              'swapfile' => {
                ensure => 'present',
              },
              'use fallocate' => {
                swapfile     => '/tmp/swapfile.fallocate',
                cmd          => 'fallocate',
                swapfilesize => '100MB'
              },
              'remove swap file' => {
                ensure       => 'absent',
                swapfile     => '/tmp/swapfile.old',
                swapfilesize => '100MB'
              },
            },
          }
        PUPPET
      end
    end

    describe file('/etc/fstab'), shell('/sbin/swapon -s') do
      its(:content) { is_expected.to match %r{/mnt/swap.1} }
      its(:content) { is_expected.to match %r{/tmp/swapfile.fallocate} }
      its(:content) { is_expected.not_to match %r{/tmp/swapfile.old} }
    end
  end
end
