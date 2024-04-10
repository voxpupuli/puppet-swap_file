# frozen_string_literal: true

require 'spec_helper'

describe 'swap_file::files' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts.merge({ memory: { system: { total: '1.00 GB' } } }) }
      let(:title) { 'default' }

      # Add these two lines in a single test block to enable puppet and hiera debug mode
      # Puppet::Util::Log.level = :debug
      # Puppet::Util::Log.newdestination(:console)

      context 'default parameters' do
        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_exec('Create swap file /mnt/swap.1').
            with('command' => '/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=1024',
                 'creates' => '/mnt/swap.1')
        end

        it do
          is_expected.to contain_file('/mnt/swap.1').
            with('owner' => 'root',
                 'group' => 'root',
                 'mode' => '0600',
                 'require' => 'Exec[Create swap file /mnt/swap.1]')
        end

        it { is_expected.to contain_swap_file('/mnt/swap.1') }

        it { is_expected.to contain_mount('/mnt/swap.1').with('require' => 'Swap_file[/mnt/swap.1]') }
      end

      context 'custom swapfilesize parameter' do
        let(:params) do
          {
            swapfilesize: '4.1 GB'
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_exec('Create swap file /mnt/swap.1').
            with('command' => '/bin/dd if=/dev/zero of=/mnt/swap.1 bs=1M count=4198',
                 'creates' => '/mnt/swap.1')
        end
      end

      context 'custom swapfilesize parameter with timeout' do
        let(:params) do
          {
            swapfile: '/mnt/swap.2',
            swapfilesize: '4.1 GB',
            timeout: 900
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_exec('Create swap file /mnt/swap.2').
            with('command' => '/bin/dd if=/dev/zero of=/mnt/swap.2 bs=1M count=4198',
                 'timeout' => 900, 'creates' => '/mnt/swap.2')
        end
      end

      context 'custom swapfilesize parameter with fallocate' do
        let(:params) do
          {
            swapfile: '/mnt/swap.3',
            swapfilesize: '4.1 GB',
            cmd: 'fallocate'
          }
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_exec('Create swap file /mnt/swap.3').
            with(
              'command' => '/usr/bin/fallocate -l 4198M /mnt/swap.3',
              'creates' => '/mnt/swap.3'
            )
        end
      end

      context 'with cmd set to invalid value' do
        let(:params) do
          {
            cmd: 'invalid'
          }
        end

        it 'fails' do
          expect { is_expected.to contain_class(subject) }.to raise_error(Puppet::Error, %r{Invalid cmd: invalid - \(Must be 'dd' or 'fallocate'\)})
        end
      end
    end
  end
end
