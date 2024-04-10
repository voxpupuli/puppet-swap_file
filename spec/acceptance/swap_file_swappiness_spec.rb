# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'swap_file::swappiness class' do
  context 'with custom parameter' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'swap_file::swappiness':
            swappiness => 75,
          }
        PUPPET
      end
    end

    describe file('/proc/sys/vm/swappiness') do
      its(:content) { is_expected.to match %r{75} }
    end
  end
end
