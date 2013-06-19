require "leveldb"

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
          klass ?
            @db.each(:from => key_for_class(klass)).map{|k,v| v } :
            @db.map{|k,v| v }
        end

        def open_store
          ::LevelDB::DB.new(@path)
        end

        def close_store
          @db.close
        end

        def key(k)
          "#{@path}.#{k}"
        end

      end # class::LevelDB
    end # class::Connection
  end # class::Model
end # module::GemVault
