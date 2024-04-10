# frozen_string_literal: true

require 'spec_helper'

describe 'swap_file' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default params' do
        it { is_expected.to contain_class('swap_file') }
        it { is_expected.to have_resource_count(0) }
      end

      context 'with files set to valid hash' do
        let(:params) do
          {
            'files' => {
              'swap' => {
                'ensure' => 'present',
              },
              'test' => {
                'swapfile' => '/mnt/test',
              },
            }
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('swap_file') }
        # subclass swap_file::files adds 4 resources for each given file
        it { is_expected.to have_resource_count(10) }

        it do
          is_expected.to contain_swap_file__files('swap').with({ 'ensure' => 'present', })
        end

        it do
          is_expected.to contain_swap_file__files('test').with({ 'swapfile' => '/mnt/test', })
        end
      end
    end
  end
end
