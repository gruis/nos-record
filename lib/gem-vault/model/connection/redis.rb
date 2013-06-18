require "redis"

module GemVault
  module Model
    class Connection
      class Redis < Connection

        PREFIX = "gem-vault"

        def initialize(path = PREFIX)
          @path   = path
          @path   = @path[0..-2] if @path[-1] == ":"
          @db     = ::Redis.new
        end

        def get(id)
          unpack(retrv("#{@path}:#{id}"))
        end

        def save(obj)
          pack = pack(obj)
          key  = "#{class_prefix(obj.class)}:#{obj.id}"
          store("#{@path}:#{key}", pack)
          key
        end

        def delete(obj)
          key = "#{@path}:#{class_prefix(obj.class)}:#{obj.id}"
          del(key)
          self
        end

        def each(klass = nil, &blk)
          return each_by_class(klass, &blk) unless klass.nil?
          @db.mget(*@db.keys("#{@path}:*")).map {|j| unpack(j) }.each(&blk)
        end

        private

        def class_prefix(klass)
          "class:#{klass.to_s.downcase}"
        end

        def retrv(key)
          @db.get(key)
        end

        def store(key, val)
          @db.set(key, val)
          self
        end

        def each_by_class(klass, &blk)
          @db.mget(*@db.keys("#{@path}:#{class_prefix(klass)}:*"))
            .map{|j| unpack(j) }
            .each(&blk)
        end

      end # class::Sqlite < Connection
    end # class::Connection
  end # module::Model
end # module::GemVault
