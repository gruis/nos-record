require "leveldb"
require "gem-vault/model/ext/leveldb"

module GemVault
  module Model
    class Connection
      class LevelDB < Connection

        DBNAME = "gem-vault.ldb"

        def initialize(path = DBNAME)
          @path = path
          open
        end


        private

        def store(key, val)
          @db[key] = val
        end

        def unstore(key)
          @db.delete(key)
        end

        def retrv(key)
          @db[key]
        end

        def values(klass = nil)
          return @db.map{|k,v| v } unless klass
          prefix = "#{key_for_class(klass)}."
          range  = 0...prefix.length
          @db.each(:from => prefix)
            .select{|k,v| k[range] == prefix }
            .map{|k,v| v }
        end

        def open_store
          ::LevelDB::DB.open(@path, :method => :new)
        end

        def close_store
          @db.close
        end

      end # class::LevelDB
    end # class::Connection
  end # class::Model
end # module::GemVault
