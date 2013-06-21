require "eventmachine"
require "nos-record/server/connection-proxy"

module NosRecord
  module Server
    module Em
      def initialize(store)
        @store  = store
        @buffer = ""
      end

      def receive_data(d)
        @buffer << d
        begin
          len_end   = @buffer.index(" ") + 1
          len       = @buffer[0..len_end].to_i + 1
          meth_data = @buffer[len_end..len]
          @buffer   = @buffer[len_end + len .. -1] || ""
          meth, data = meth_data.split(" ", 2)
        rescue => e
          send_data("Parse Error: #{e}")
          $stderr.puts e
          $stderr.puts e.backtrace
        end

        begin
          case meth
          when 'retrv'
            send_data(@store.retrv(data))
          when 'unstore'
            send_data(@store.unstore(data))
          when 'store'
            send_data(@store.store(*data.split(" ", 2)))
          when 'values'
            send_data(@store.values(data))
          else
            send_data("Request Error: unrecognized request '#{meth}'")
          end
        rescue => e
          send_data("Datastore Error: #{e}")
          $stderr.puts e
          $stderr.puts e.backtrace
        end
      end

      def send_data(d)
        s = "#{d}"
        super("#{s.length + 1} #{s}")
      end

    end # module::Em
  end # module::Server
end # module::NosRecord
