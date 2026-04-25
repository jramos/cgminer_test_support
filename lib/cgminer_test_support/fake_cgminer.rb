# frozen_string_literal: true

require 'socket'
require 'json'

module CgminerTestSupport
  # In-process TCP server that speaks the cgminer JSON API. Used by
  # integration specs and manual sandboxes across the cgminer Ruby
  # ecosystem. Per-connection error handling swallows StandardError so
  # one bad client can't take the server down. Stop semantics close the
  # listening socket FIRST so macOS Thread#kill (which doesn't interrupt
  # a thread blocked in C-level accept) doesn't leak a zombie.
  class FakeCgminer
    attr_reader :host, :port

    def initialize(responses: Fixtures::DEFAULT, port: 0, host: '127.0.0.1', on_request: nil)
      @responses  = responses
      @host       = host
      @on_request = on_request
      @server     = TCPServer.new(host, port)
      @port       = @server.addr[1]
      @thread     = nil
    end

    def start
      @thread = Thread.new { accept_loop }
      self
    end

    def stop
      # Close the listener BEFORE joining. On macOS, Thread#kill does
      # not reliably interrupt a thread blocked in C-level accept, so
      # join would hang. Closing the socket causes accept to raise
      # IOError, which accept_next_client catches.
      @server.close unless @server.closed?
      @thread&.join
    end

    # Bracket a block with start/stop. Cleans up even if the block
    # raises. Yields the port the server is listening on.
    def self.with(**)
      server = new(**).start
      begin
        yield server.port
      ensure
        server.stop
      end
    end

    private

    def accept_loop
      loop do
        client = accept_next_client
        break if client.nil? # listening socket closed by #stop

        handle_connection_safely(client)
      end
    end

    def accept_next_client
      @server.accept
    rescue IOError, Errno::EBADF
      nil
    end

    # Per-connection isolation: any error in handling one request
    # (EOFError from a probe-and-close, JSON parse failure, write
    # error) is swallowed so the next connection still gets served.
    def handle_connection_safely(client)
      handle_request(client)
    rescue StandardError
      # ignore — next connection unaffected
    end

    def handle_request(client)
      request_bytes = read_until_parseable(client)
      @on_request&.call(request_bytes)
      request = JSON.parse(request_bytes)
      client.write(lookup_response(request['command']))
    ensure
      client&.close
    end

    # Real cgminer requests fit in one TCP packet over loopback so this
    # is almost always a single readpartial. Loop is here for
    # correctness if a request is ever fragmented.
    def read_until_parseable(client)
      buf = +''
      loop do
        buf << client.readpartial(4096)
        return buf if complete_json?(buf)
      end
    end

    def complete_json?(buf)
      JSON.parse(buf)
      true
    rescue JSON::ParserError
      false
    end

    def lookup_response(command)
      @responses.fetch(command) { Fixtures.invalid_command(command) }
    end
  end
end
