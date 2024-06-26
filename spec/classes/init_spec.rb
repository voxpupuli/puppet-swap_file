# frozen_string_literal: true

require 'spec_helper'
describe 'swap_file' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts.merge({
                         memory: {
                           system: {
                             total: '1.00 GB',
                           }
                         },
                         parameter_tests: '', # Default so hiera does not fail.
                       })
      end

      context 'with defaults for all parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('swap_file') }
        it { is_expected.to have_resource_count(0) }
      end

      context 'with files set to valid hash' do
        let(:params) do
          {
            files: {
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
          is_expected.to contain_swap_file__files('swap').with({
                                                                 'ensure' => 'present',
                                                               })
        end

        it do
          is_expected.to contain_swap_file__files('test').with({
                                                                 'swapfile' => '/mnt/test',
                                                               })
        end
      end

      describe 'with data for swap_file::files provided in multiple hiera levels' do
        let(:facts) do
          super().merge(
            {
              fqdn:            'files',
              parameter_tests: 'files_hiera_merge',
            }
          )
        end

        context 'when files_hiera_merge is set to the default value <false>' do
          let(:params) { { files_hiera_merge: false } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('swap_file') }
          it { is_expected.to have_resource_count(5) }

          it do
            is_expected.to contain_swap_file__files('resource_name').with({
                                                                            'ensure'   => 'present',
                                                                            'swapfile' => '/mnt/swap',
                                                                          })
          end
        end

        context 'when files_hiera_merge is set to valid value <true>' do
          let(:params) { { files_hiera_merge: true } }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('swap_file') }
          it { is_expected.to have_resource_count(15) }

          it do
            is_expected.to contain_swap_file__files('resource_name').with({
                                                                            'ensure'   => 'present',
                                                                            'swapfile' => '/mnt/swap',
                                                                          })
          end

          it do
            is_expected.to contain_swap_file__files('swap1').with({
                                                                    'ensure' => 'present',
                                                                    'swapfile' => '/mnt/swap.1',
                                                                    'swapfilesize' => '1 GB',
                                                                  })
          end

          it do
            is_expected.to contain_swap_file__files('swap2').with({
                                                                    'ensure' => 'present',
                                                                    'swapfile' => '/mnt/swap.2',
                                                                    'swapfilesize' => '2 GB',
                                                                    'cmd' => 'fallocate',
                                                                  })
          end
        end
      end

      describe 'variable type and content validations' do
        # set needed variables
        let(:validation_params) do
          {
            # :param => 'value',
          }
        end

        validations = {
          'bool_stringified' => {
            name: %w[files_hiera_merge],
            valid: [true, false, 'true', 'false'],
            invalid: ['invalid', %w[array], { 'ha' => 'sh' }, 3, 2.42, nil],
            message: 'value of type Boolean',
          },
          'hash' => {
            name: %w[files],
            valid: [{ 'swap' => { 'ensure' => 'present' } }],
            invalid: ['invalid', %w[array], 3, 2.42, true, false, nil],
            message: '(is not a Hash|expects a Hash value, got)',
          },
        }

        validations.sort.each do |type, var|
          var[:name].each do |var_name|
            var[:valid].each do |valid|
              context "with #{var_name} (#{type}) set to valid #{valid} (as #{valid.class})" do
                let(:params) { validation_params.merge({ "#{var_name}": valid, }) }

                it { is_expected.to compile }
              end
            end

            var[:invalid].each do |invalid|
              context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
                let(:params) { validation_params.merge({ "#{var_name}": invalid, }) }

                it 'fails' do
                  expect do
                    is_expected.to contain_class(subject)
                  end.to raise_error(Puppet::Error, %r{#{var[:message]}})
                end
              end
            end
          end
        end
      end
    end
  end
end
