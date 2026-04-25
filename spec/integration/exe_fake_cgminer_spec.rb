# frozen_string_literal: true

require 'spec_helper'
require 'open3'
require 'socket'
require 'json'

RSpec.describe 'exe/fake_cgminer', type: :integration do
  it 'binds to the requested port and serves a Fixtures::DEFAULT response' do
    port = 39_999
    exe  = File.expand_path('../../exe/fake_cgminer', __dir__)
    pid  = nil

    begin
      stdin, stdout_err, wait_thr = Open3.popen2e(exe, port.to_s)
      pid = wait_thr.pid

      # Wait up to 3s for the listener.
      30.times do
        TCPSocket.new('127.0.0.1', port).close
        break
      rescue Errno::ECONNREFUSED
        sleep 0.1
      end

      sock = TCPSocket.new('127.0.0.1', port)
      sock.write(JSON.generate(command: 'restart'))
      sock.shutdown(:WR)
      body = sock.read
      sock.close

      envelope = JSON.parse(body)
      expect(envelope['STATUS'].first).to include('STATUS' => 'S', 'Code' => 42)
    ensure
      Process.kill('TERM', pid) if pid
      stdin&.close
      stdout_err&.close
      wait_thr&.join(2)
    end
  end
end
