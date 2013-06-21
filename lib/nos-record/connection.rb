require "oj"

module NosRecord
  class Connection

    include Enumerable

    def get(id, klass)
      j = retrv(key_for(id, klass))
      j && unpack(j)
    end

    def save(obj)
      raise IdRequired.new("#{obj.class} must contain an id") unless obj.respond_to?(:id) && obj.id
      pack = pack(obj)
      store(key_for(obj.id, obj.class), pack)
      self
    end

    def delete(obj)
      unstore(key_for(obj.id, obj.class))
    end

    def each(klass = nil, &blk)
      values(klass)
        .map{|j| o = unpack(j) }
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

    protected


    def retrv(key)
      raise ConnectionRequired
    end

    def store(key, value)
      raise ConnectionRequired
    end

    def unstore(key, value)
      raise ConnectionRequired
    end

    private


    def open_store
      raise ConnectionRequired
    end

    def close_store
      raise ConnectionRequired
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
      klass.is_a?(String) ?  "class.#{klass}" : "class.#{klass.to_s.downcase}"
    end

    def values(klass = nil)
      raise ConnectionRequired
    end

    def pack(obj)
      Oj.dump(obj)
    end

    def unpack(json)
      o = Oj.load(json)
      if o.class.respond_to?(:default_connection) && o.class.default_connection != self
        o.instance_variable_set(:@_connection, self)
      end
      o
    end

  end # class::Connection
end # module::NosRecord

require "nos-record/connection/leveldb"
require "nos-record/connection/redis"
require "nos-record/connection/sqlite"
require "nos-record/connection/kyoto-cabinet"
