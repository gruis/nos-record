require "oj"

module GemVault
  module Model
    class Connection

      include Enumerable

      def get(id, klass)
        j = retrv(key_for(id, klass))
        j && unpack(j)
      end

      def save(obj)
        raise "#{obj.class} must contain an id" unless obj.respond_to?(:id) && obj.id
        pack = pack(obj)
        k = key_for(obj.id, obj.class)
        store(k, pack)
        k
      end

      def delete(obj)
        unstore(key_for(obj.id, obj.class))
      end

      def each(klass = nil, &blk)
        values(klass)
          .map{|j| unpack(j) }
          .each(&blk)
      end

      def close
        return unless @db
        close_store
        @db = nil
      end

      def open
        @db ||= open_store
      end
      alias :db :open

      private


      def retrv(key)
        raise NotImplementedError
      end

      def store(key, value)
        raise NotImplementedError
      end

      def unstore(key, value)
        raise NotImplementedError
      end

      def open_store
        raise NotImplementedError
      end

      def close_store
        raise NotImplementedError
      end

      def key(k)
        k
      end

      def key_for_class(klass)
        key(class_prefix(klass))
      end

      def key_for(id, klass)
        key("#{class_prefix(klass)}.#{id}")
      end

      def class_prefix(klass)
        "class.#{klass.to_s.downcase}"
      end

      def values(klass = nil)
        raise NotImplementedError
      end

      def pack(obj)
        Oj.dump(obj)
      end

      def unpack(json)
        o = Oj.load(json)
        o.instance_variable_set(:@_connection, self) unless o.class.default_connection == self
        o
      end

    end # class::Connection
  end # class::Model
end # module::GemVault

require "gem-vault/model/connection/leveldb"
require "gem-vault/model/connection/redis"
require "gem-vault/model/connection/sqlite"
require "gem-vault/model/connection/kyoto-cabinet"
