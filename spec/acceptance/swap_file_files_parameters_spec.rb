# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'swap_file::files defined type' do
  context 'swap_file' do
    context 'custom parameters' do
      it 'works with no errors' do
        pp = <<-EOS
        swap_file::files { 'tmp file swap':
          ensure   => present,
          swapfile => '/mnt/swapfile',
        }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'contains the given swapfile' do
        if ['FreeBSD'].include?(fact('os.family'))
          shell('/usr/sbin/swapinfo | grep /dev/md99', acceptable_exit_codes: [0])
        else
          shell('/sbin/swapon -s | grep /mnt/swapfile', acceptable_exit_codes: [0])
        end
      end

      it 'contains the given fstab setting' do
        shell('cat /etc/fstab | grep /mnt/swapfile', acceptable_exit_codes: [0])
        if ['FreeBSD'].include?(fact('os.family'))
          shell('cat /etc/fstab | grep md99', acceptable_exit_codes: [0])
        else
          shell('cat /etc/fstab | grep defaults', acceptable_exit_codes: [0])
        end
      end
    end
  end
end
