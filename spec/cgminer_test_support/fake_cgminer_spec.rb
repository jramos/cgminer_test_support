# frozen_string_literal: true

require 'spec_helper'
require 'socket'
require 'json'

RSpec.describe CgminerTestSupport::FakeCgminer do
  describe '.with' do
    it 'starts and stops a TCP server inside the block, yielding the chosen port', :aggregate_failures do
      block_port = nil
      described_class.with do |port|
        block_port = port
        sock = TCPSocket.new('127.0.0.1', port)
        sock.write(JSON.generate(command: 'summary'))
        sock.shutdown(:WR)
        body = sock.read
        sock.close
        envelope = JSON.parse(body)
        expect(envelope['SUMMARY']).to be_an(Array)
      end
      expect(block_port).to be > 0
      # After the block, the port is closed.
      expect { TCPSocket.new('127.0.0.1', block_port) }.to raise_error(Errno::ECONNREFUSED)
    end
  end

  describe 'unknown commands fall through to invalid_command' do
    it 'returns STATUS=E Code=14 for a verb not in DEFAULT' do
      described_class.with do |port|
        sock = TCPSocket.new('127.0.0.1', port)
        sock.write(JSON.generate(command: 'definitelynotacommand'))
        sock.shutdown(:WR)
        body = sock.read
        sock.close
        envelope = JSON.parse(body)
        expect(envelope['STATUS'].first).to include('STATUS' => 'E', 'Code' => 14)
      end
    end
  end

  describe 'custom responses:' do
    it 'serves a caller-supplied response map' do
      custom = { 'summary' => '{"STATUS":[{"STATUS":"S","Code":11}],"SUMMARY":[{"x":1}]}' }
      described_class.with(responses: custom) do |port|
        sock = TCPSocket.new('127.0.0.1', port)
        sock.write(JSON.generate(command: 'summary'))
        sock.shutdown(:WR)
        body = sock.read
        sock.close
        expect(JSON.parse(body)['SUMMARY']).to eq([{ 'x' => 1 }])
      end
    end
  end

  describe 'on_request: callback' do
    it 'fires once per request with the raw request bytes (not the parsed hash)', :aggregate_failures do
      seen = []
      described_class.with(on_request: ->(bytes) { seen << bytes }) do |port|
        sock = TCPSocket.new('127.0.0.1', port)
        sock.write(JSON.generate(command: 'summary', parameter: '1'))
        sock.shutdown(:WR)
        sock.read
        sock.close
      end
      expect(seen.size).to eq(1)
      expect(seen.first).to be_a(String)
      expect(seen.first).to include('"command":"summary"')
      expect(seen.first).to include('"parameter":"1"')
    end
  end

  describe 'host:' do
    it 'binds to the supplied host (default 127.0.0.1)' do
      server = described_class.new(host: '127.0.0.1', port: 0).start
      expect(server.host).to eq('127.0.0.1')
      server.stop
    end
  end

  describe 'concurrent connections do not crash the server' do
    it 'survives a malformed request and continues serving' do
      described_class.with do |port|
        bad = TCPSocket.new('127.0.0.1', port)
        bad.write('this is not json at all')
        bad.shutdown(:WR)
        bad.read # may be empty or an error envelope
        bad.close

        good = TCPSocket.new('127.0.0.1', port)
        good.write(JSON.generate(command: 'summary'))
        good.shutdown(:WR)
        body = good.read
        good.close
        expect(JSON.parse(body)['SUMMARY']).to be_an(Array)
      end
    end
  end

  describe '#start returns self for chaining' do
    it 'lets callers do FakeCgminer.new(...).start', :aggregate_failures do
      server = described_class.new(port: 0).start
      expect(server).to be_a(described_class)
      expect(server.port).to be > 0
      server.stop
    end
  end

  describe '#port is known immediately after .new (before #start)' do
    # Existing callers (e.g. cgminer_manager/spec/integration/admin_spec.rb)
    # do `let(:fake) { FakeCgminer.new(...).start }` and elsewhere
    # reference `fake.port` in `let(:miners_file)` blocks that are
    # evaluated before `fake` itself materializes. This works only
    # because the TCPServer opens in initialize. Pin the invariant.
    it 'opens the listening socket in initialize' do
      server = described_class.new(port: 0)
      expect(server.port).to be > 0
      server.stop
    end
  end
end
