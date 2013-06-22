require "eventmachine"
require "nos-record/server/connection-proxy"
require "nos-record/server"

module NosRecord
  module Server
    module Em
      def initialize(store, &blk)
        @store  = store
        @buffer = ""
      end

      def receive_data(d)
        # TODO handle more than one request in the buffer
        begin
          @buffer << d
          meth, len = @buffer[0..5].unpack(HDR_FMT)
          len       = len + 5
          data      = @buffer[5..len]
          @buffer   = @buffer[5+len..-1] || ""
        rescue => e
          send_resp(PARSE_ERROR, "#{e}")
          $stderr.puts e
          $stderr.puts e.backtrace
          return
        end
        process_request(meth, data)
      end

      def process_request(meth, data)
        case meth
        when RETRV
          send_resp(OK, @store.retrv(data))
        when UNSTORE
          send_resp(OK, @store.unstore(data))
        when STORE
          send_resp(OK, @store.store(*data.split(" ", 2)))
        when VALUES
          send_resp(OK, @store.values(data.empty? ? nil : data))
        else
          send_resp(REQ_ERROR, "unrecognized request '#{meth}'")
        end
      rescue => e
        send_resp(DS_ERROR, "#{e}")
        $stderr.puts e
        $stderr.puts e.backtrace
      end

      def send_resp(code, body)
        b = "#{body}"
        send_data("#{[code, b.length].pack(HDR_FMT)}#{b}")
      end

    end # module::Em
  end # module::Server
end # module::NosRecord
