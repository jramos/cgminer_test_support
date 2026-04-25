# frozen_string_literal: true

require 'spec_helper'
require 'json'

RSpec.describe CgminerTestSupport::Fixtures do
  describe 'STATUS letters' do
    it 'PRIVILEGED_DENIED is STATUS=E' do
      expect(JSON.parse(described_class::PRIVILEGED_DENIED)['STATUS'].first['STATUS']).to eq('E')
    end

    %w[SUMMARY DEVS POOLS STATS ADDPOOL_OK PRIVILEGED_OK
       RESTART_OK QUIT_OK ZERO_OK SAVE_OK].each do |name|
      it "#{name} is STATUS=S" do
        expect(JSON.parse(described_class.const_get(name))['STATUS'].first['STATUS']).to eq('S')
      end
    end
  end

  describe 'POOLS_WITH_CONTROL_BYTE' do
    # cgminer_api_client/spec/integration/miner_integration_spec.rb:64
    # asserts the control byte survives in the URL field. Pin both the
    # encoding AND the byte placement so a future edit can't silently
    # break that assertion.
    it 'is ASCII-8BIT-encoded and contains a raw 0x01 byte', :aggregate_failures do
      raw = described_class::POOLS_WITH_CONTROL_BYTE
      expect(raw.encoding).to eq(Encoding::ASCII_8BIT)
      expect(raw).to include("\x01")
    end
  end

  describe '.invalid_command' do
    it 'embeds the verb name in Description (the contract miner_integration_spec matches against)',
       :aggregate_failures do
      envelope = JSON.parse(described_class.invalid_command('bogus'))
      expect(envelope['STATUS'].first).to include('STATUS' => 'E', 'Code' => 14)
      expect(envelope['STATUS'].first['Msg']).to match(/Invalid command/i)
      expect(envelope['STATUS'].first['Description']).to include('(bogus)')
    end
  end

  describe 'DEFAULT' do
    it 'maps every documented command name to a fixture string' do
      expect(described_class::DEFAULT.keys).to contain_exactly(
        'summary', 'devs', 'pools', 'stats', 'summary+pools',
        'addpool', 'privileged',
        'restart', 'quit', 'zero', 'save'
      )
    end
  end

  describe 'WHEN' do
    it 'is the canonical 1_700_000_000 epoch the source files use' do
      expect(described_class::WHEN).to eq(1_700_000_000)
    end
  end
end
