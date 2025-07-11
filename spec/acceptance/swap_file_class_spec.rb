# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'swap_file class' do
  context 'swap_file' do
    context 'ensure => present' do
      it 'works with no errors' do
        pp = <<-EOS
        class { 'swap_file':
          files => {
            'swapfile' => {
              ensure => 'present',
            },
            'use fallocate' => {
              swapfile => '/mnt/swapfile.fallocate',
              cmd      => 'fallocate',
            },
            'remove swap file' => {
              ensure   => 'absent',
              swapfile => '/mnt/swapfile.old',
            },
          },
        }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'contains the default swapfile' do
        shell('/sbin/swapon -s | grep /mnt/swap.1', acceptable_exit_codes: [0])
      end

      it 'contains the default fstab setting' do
        shell('cat /etc/fstab | grep /mnt/swap.1', acceptable_exit_codes: [0])
        shell('cat /etc/fstab | grep defaults', acceptable_exit_codes: [0])
      end

      it 'contains the default swapfile' do
        shell('/sbin/swapon -s | grep /mnt/swapfile.fallocate', acceptable_exit_codes: [0])
      end

      it 'contains the default fstab setting' do
        shell('cat /etc/fstab | grep /mnt/swapfile.fallocate', acceptable_exit_codes: [0])
      end
    end
  end
end
