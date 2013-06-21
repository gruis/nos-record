require "nos-record/connection"
module NosRecord
  class Client < Connection
    def initialize(host, port)
      @host = host
      @port = port
      open
    end

    def retrv(key)
      send_request(:retrv, key)
    end

    def store(key, value)
      send_request(:store, key, value)
    end

    def unstore(key)
      send_request(:unstore, key)
    end

    def values(klass = nil)
      vals = (klass ? send_request(:values, klass) : send_request(:values))
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

    def send_request(req, *args)
      data = "#{req}"
      data << " #{args.join(" ")}" unless args.empty?
      @sock.print("#{data.length + 1} #{data}")
      len = ""
      len << @sock.recv(1) while len[-1] != " "
      len = len[0..-2].to_i
      return nil if len == 0
      @sock.recv(len - 1)
    end

  end # class::Client < Connection
end # module::NosRecord
