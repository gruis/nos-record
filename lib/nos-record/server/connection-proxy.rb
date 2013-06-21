require "nos-record/connection"

module NosRecord
  module Server
    # Connection keeps its low-level retrv, store, etc., methods
    # protected. Use an instnace of a ConnectionProxy to access those
    # methods.
    module ConnectionProxy
      class << self
        def proxy(con)
          case con
          when Connection::LevelDB
            LevelDB.new(con)
          when Connection::KyotoCabinet
            KyotoCabinet.new(con)
          when Connection::Redis
            Redis.new(con)
          when Connection::Sqlite
            Sqlite.new(con)
          else
            raise "unsupported connection type #{con.class}"
          end
        end
      end

      def initialize(con)
        @con = con
      end

      def retrv(key)
        @con.retrv(key)
      end

      def store(key, value)
        @con.store(key, value)
      end

      def unstore(key)
        @con.unstore(key)
      end

      def values(klass = nil)
        @con.values(klass)
      end


      class LevelDB < Connection::LevelDB
        include ConnectionProxy
      end
      class KyotoCabinet < Connection::KyotoCabinet
        include ConnectionProxy
      end
      class Redis < Connection::Redis
        include ConnectionProxy
      end
      class Sqlite < Connection::Sqlite
        include ConnectionProxy
      end
    end # module::ConnectionProxy
  end # module::Server
end # module::NosRecord
