# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CgminerTestSupport do
  it 'has a SemVer-shaped VERSION' do
    expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
