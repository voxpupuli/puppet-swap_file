# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'swap_file::files defined type' do
  context 'swap_file' do
    context 'custom parameters' do
      it 'works with no errors' do
        pp = <<-EOS
        swap_file::files { 'tmp file swap':
          ensure   => present,
          swapfile => '/tmp/swapfile',
        }
        EOS

        apply_manifest(pp, catch_failures: true)
        apply_manifest(pp, catch_changes: true)
      end

      it 'contains the given swapfile' do
        shell('/sbin/swapon -s | grep /tmp/swapfile', acceptable_exit_codes: [0])
      end

      it 'contains the given fstab setting' do
        shell('cat /etc/fstab | grep /tmp/swapfile', acceptable_exit_codes: [0])
        shell('cat /etc/fstab | grep defaults', acceptable_exit_codes: [0])
      end
    end
  end
end
