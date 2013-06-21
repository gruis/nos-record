require "nos-record/server"
require "nos-record/connection"
module NosRecord
  class Client < Connection
    def initialize(host, port)
      @host = host
      @port = port
      open
    end

    def retrv(key)
      send_request(Server::RETRV, key)
    end

    def store(key, value)
      send_request(Server::STORE, key, value)
    end

    def unstore(key)
      send_request(Server::UNSTORE, key)
    end

    def values(klass = nil)
      vals = (klass ? send_request(Server::VALUES, klass) : send_request(Server::VALUES))
      vals ? Oj.load(vals) : []
    end

    def open
      @sock = TCPSocket.open(@host, @port)
      self
    end

    def close
      @sock.close
      self
    end

    private

    def send_request(code, *args)
      body = args.empty? ? "" : args.join(" ")
      data = [code, body.length].pack("CL")
      data = "#{data}#{body}"
      @sock.print(data)
      wait_for_response
    end

    def wait_for_response
      code, len = @sock.recv(5).unpack("CL")
      # TODO raise errors based on return code
      return nil if len == 0
      body = @sock.recv(len)
      body << @sock.recv(len - body.length) while body.length < len
      body
    end

  end # class::Client < Connection
end # module::NosRecord
