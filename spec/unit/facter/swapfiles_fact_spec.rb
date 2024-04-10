# frozen_string_literal: true

require 'spec_helper'

describe Facter::Util::Fact do
  before { Facter.clear }

  describe 'swapfile_sizes' do
    context 'returns swapfile_sizes when present' do
      it do
        allow(File).to receive(:exist?).with('/proc/swaps').and_return true
        allow(Facter.fact(:kernel)).to receive(:value).once.and_return('Linux')
        allow(Facter::Util::Resolution).to receive(:exec).with('cat /proc/swaps').and_return <<~EOS
          Filename        Type    Size  Used  Priority
          /dev/dm-1                               partition 524284  0 -1
          /mnt/swap.1                             file      204796  0 -2
          /tmp/swapfile.fallocate                 file      204796  0 -3
        EOS
        expect(Facter.value(:swapfile_sizes)).to eq(
          {
            '/mnt/swap.1' => '204796',
            '/tmp/swapfile.fallocate' => '204796'
          }
        )
      end
    end
  end
end
