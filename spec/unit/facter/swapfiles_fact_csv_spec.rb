# frozen_string_literal: true

require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
    allow(File).to receive(:exist?).with('/proc/swaps').and_return true
    allow(Facter.fact(:kernel)).to receive(:value).once.and_return('Linux')
  end

  describe 'swapfile_sizes_csv' do
    context 'returns swapfile_sizes when present' do
      it do
        allow(Facter::Util::Resolution).to receive(:exec).with('cat /proc/swaps').and_return <<~EOS
          Filename        Type    Size  Used  Priority
          /dev/dm-1                               partition 524284  0 -1
          /mnt/swap.1                             file      204796  0 -2
          /tmp/swapfile.fallocate                 file      204796  0 -3
        EOS
        expect(Facter.value(:swapfile_sizes_csv)).to eq('/mnt/swap.1||204796,/tmp/swapfile.fallocate||204796')
      end
    end

    context 'returns nil when no swapfiles' do
      it do
        allow(Facter::Util::Resolution).to receive(:exec).with('cat /proc/swaps').and_return <<~EOS
          Filename        Type    Size  Used  Priority
          /dev/dm-2                               partition 16612860  0 -1
        EOS
        expect(Facter.value(:swapfile_sizes_csv)).to be_nil
      end
    end
  end
end
