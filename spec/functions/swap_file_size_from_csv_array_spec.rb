# frozen_string_literal: true

require 'spec_helper'

describe 'swap_file_size_from_csv' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.not_to be_nil }
      it { is_expected.to run.with_params([]).and_raise_error(Puppet::ParseError, %r{Wrong number of arguments given \(1 for 2\)}i) }
      it { is_expected.to run.with_params(%w[1 2]).and_raise_error(Puppet::ParseError, %r{Wrong number of arguments given \(1 for 2\)}i) }
      it { is_expected.to run.with_params([], '2').and_raise_error(Puppet::ParseError, %r{swapfile name but be a string}i) }

      it { is_expected.to run.with_params('/mnt/swap.1', '/mnt/swap.1||1019900,/mnt/swap.1||1019900').and_return('1019900') }
      it { is_expected.to run.with_params('/mnt/swap.2', '/mnt/swap.1||1019900,/mnt/swap.1||1019900').and_return(false) }
    end
  end
end
