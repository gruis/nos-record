require "leveldb"
require "oj"

module GemVault
  module Model
    class Connection

      DBNAME = "gem-vault.db"

      include Enumerable

      def initialize(path = DBNAME)
        @path = path
      end

      def get(id)
        open {|db| unpack(db["#{id}"]) }
      end

      def each(klass = nil, &blk)
        return each_by_class(klass, &blk) unless klass.nil?
        open do |db|
          db.map{|k,v| unpack(b) }.each(&blk)
        end
      end

      def save(obj)
        pack      = pack(obj)
        class_key = "idx:class:#{obj.class}"
        key       = "#{obj.id}"
        open do |db|
          # TODO keep old versions
          db[key] = pack
          db.batch do |trans|
            recs      = db[class_key]
            recs      = recs ? unpack(recs) : {}
            recs[key] = true
            trans.put(class_key, pack(recs))
          end
        end
      end

      def delete(obj)
        class_key = "id:class:#{obj.class}"
        open do |db|
          db.batch do |trans|
            trans.delete(obj.id)
            if trans.includes?(class_key)
              recs = unpack(db[class_key])
              recs.delete(obj.id)
              trans.put(class_key, pack(recs))
            end
          end
        end
      end


      private

      def pack(obj)
        Oj.dump(obj)
      end

      def unpack(json)
        o = Oj.load(json)
        o.instance_variable_set(:@_connection, self)
        o
      end

      def each_by_class(klass, &blk)
        open do |db|
          return [] unless db.includes?("idx:class:#{klass}")
          unpack(db["idx:class:#{klass}"])
            .keys
            .map{|k| unpack(db[k]) }
            .each(&blk)
        end
      end

      def open
        return yield(@db) if @db
        tries = 10
        begin
          yield(@db = LevelDB::DB.new(@path))
        rescue  LevelDB::Error => e
          if (tries =- 1) > 0
            sleep rand
            retry
          else
            raise
          end
        end
      ensure
        #@db && @db.close
        #remove_instance_variable(:@db)
      end

    end # class::Connection
  end # class::Model
end # module::GemVault
