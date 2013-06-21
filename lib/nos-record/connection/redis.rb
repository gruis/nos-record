require "redis"

module NosRecord
  class Connection
    class Redis < Connection

      PREFIX = "nos-record"

      def initialize(opts = {})
        @path       = opts.delete(:prefix) || PREFIX
        @path       = @path[0..-2] if @path[-1] == ":"
        @redis_opts = opts
        open
      end


      protected

      def retrv(key)
        @db.get(key)
      end

      def store(key, val)
        @db.set(key, val)
        self
      end

      def unstore(key)
        @db.del(key)
      end

      def values(klass = nil)
        keys = @db.keys(klass ? "#{key_for_class(klass)}.*" : key("*"))
        return [] if keys.empty?
        @db.mget(*keys)
      end


      private

      def open_store
        ::Redis.new(@redis_opts)
      end

      def close_store
        @db.close
      end

      def key(k)
        "#{@path}.#{k}"
      end

    end # class::Redis < Connection
  end # class::Connection
end # module::NosRecord
