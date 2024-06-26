# frozen_string_literal: true

require 'spec_helper'

describe 'swap_file::swappiness' do
  let(:params) do
    {
      swappiness: 65,
    }
  end

  it do
    is_expected.to contain_sysctl('vm.swappiness').
      with({ 'ensure' => 'present',
             'value' => '65' })
  end
end
