require "kyotocabinet"

module NosRecord
  class Connection
    class KyotoCabinet < Connection

      DBNAME = "nos-record.kch"

      def initialize(path = DBNAME)
        @path = path
        open
      end


      protected

      def retrv(key)
        @db.get(key)
      end

      def store(key, val)
        @db.set(key, val) || raise("set error '#{key}': #{db.error}")
        self
      end

      def unstore(key)
        @db.del(key)
        self
      end

      def values(klass = nil)
        unless klass.nil?
          recs = @db.get_bulk(@db.match_prefix(key_for_class(klass)))
          return recs ? recs.values : []
        end
        recs = []
        @db.each_value { |v| recs << v[0] }
        return recs
      end

      private

      def close_store
        @db.close
      end

      def open_store
        db = ::KyotoCabinet::DB::new
        unless db.open(@path, ::KyotoCabinet::DB::OWRITER | ::KyotoCabinet::DB::OCREATE)
          raise "open error '#{@path}': #{db.error}"
        end
        db
      end

    end # class::KyotoCabinet < Connection
  end # class::Connection
end # module::NosRecord
