#!/usr/bin/env ruby
# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:swap_file) do
  before do
    @class = described_class
    @provider_class = @class.provide(:fake) { mk_resource_methods } # rubocop:todo RSpec/InstanceVariable
    @provider = @provider_class.new # rubocop:todo RSpec/InstanceVariable

    allow(@class).to receive(:defaultprovider).and_return(@provider_class) # rubocop:todo RSpec/InstanceVariable
  end

  it 'has :name as its keyattribute' do
    expect(@class.key_attributes).to eq([:file]) # rubocop:todo RSpec/InstanceVariable
  end

  describe 'when validating attributes' do
    params = [
      :file,
    ]

    properties = %i[
      type
      size
      used
      priority
    ]

    params.each do |param|
      it "has a #{param} parameter" do
        expect(@class.attrtype(param)).to eq(:param) # rubocop:todo RSpec/InstanceVariable
      end
    end

    properties.each do |prop|
      it "has a #{prop} property" do
        expect(@class.attrtype(prop)).to eq(:property) # rubocop:todo RSpec/InstanceVariable
      end
    end

    %w[. ./foo \foo C:/foo \\Server\Foo\Bar \\?\C:\foo\bar \/?/foo\bar \/Server/foo foo//bar/baz].each do |invalid_path|
      context "path => #{invalid_path}" do
        it 'requires a valid path for file' do
          expect do
            @class.new({ file: invalid_path }) # rubocop:todo RSpec/InstanceVariable
          end.to raise_error(Puppet::ResourceError, %r{file parameter must be a valid absolute path})
        end
      end
    end

    %w[/ /foo /foo/../bar //foo //Server/Foo/Bar //?/C:/foo/bar /\Server/Foo /foo//bar/baz].each do |valid_path|
      context "path => #{valid_path}" do
        it 'allows a valid path for file' do
          expect do
            @class.new({ file: valid_path }) # rubocop:todo RSpec/InstanceVariable
          end.not_to raise_error
        end
      end
    end
  end
end
