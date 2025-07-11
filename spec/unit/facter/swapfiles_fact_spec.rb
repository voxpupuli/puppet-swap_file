# frozen_string_literal: true

require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  describe 'swapfile_sizes' do
    context 'returns swapfile_sizes when present' do
      before do
        allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
        allow(File).to receive(:exist?).with('/proc/swaps').and_return(true)
        allow(Facter::Util::Resolution).to receive(:exec)
      end

      it do
        proc_swap_output = <<~EOS
          Filename        Type    Size  Used  Priority
          /dev/dm-1                               partition 524284  0 -1
          /mnt/swap.1                             file      204796  0 -2
          /tmp/swapfile.fallocate                 file      204796  0 -3
        EOS
        allow(Facter::Util::Resolution).to receive(:exec).with('cat /proc/swaps').and_return(proc_swap_output)
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
