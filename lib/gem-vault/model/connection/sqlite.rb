require "sqlite3"

module GemVault
  module Model
    class Connection
      class Sqlite < Connection

        DBNAME = "gem-vault.sqlite"

        def initialize(path = DBNAME)
          @path   = path
          @db     = SQLite3::Database.new(@path)
          @tables = {}
          Model.models.each { |klass| setup_for_class(klass) }
          use("[generic.object]")
        end

        def get(id)
          unpack(retrv(id))
        end

        def use(table)
          @table = table
          create(table) unless table_exists?(table)
        end

        def save(obj)
          pack      = pack(obj)
          class_key = "idx:class:#{obj.class}"
          key       = "#{obj.id}"
          store(key, pack)
          recs = retrv(class_key)
          recs = recs ? unpack(recs) : {}
          recs[key] = true
          store(class_key, pack(recs))
          key
        end

        def delete(obj)
          class_key = "id:class:#{obj.class}"
          del(obj.id)
          recs = retrv(class_key)
          if recs && recs = unpack(recs)
            recs.delete(obj.id)
            store(class_key, pack(recs))
          end
          self
        end


        private

        def retrv(key, table = @table)
          results = @db.get_first_row("SELECT value FROM #{table} WHERE key='#{key}'")
          results && results[0]
        end

        def store(key, val, table = @table)
          sql    = "REPLACE INTO #{table} (key, value) VALUES ('#{key}', '#{val}')"
          result = @db.execute(sql)
          self
        end

        def setup_for_class(klass)
          table = "[#{klass}]".downcase.gsub("::", ".")
          create(table) unless table_exists?(table)
          @tables[klass] = table
        end

        def create(table)
          sql = "CREATE TABLE #{table} (key varchar(100) PRIMARY KEY, value varchar(1000))"
          @db.execute(sql)
          self
        end

        def del(key, table = @table)
          @db.execute("DELETE FROM #{table} WHERE key='#{key}'")
        end

        def table_exists?(tbl)
          tbl = tbl[1..-2] if tbl[0] == "[" && tbl[-1] == "]"
          @db.get_first_row("SELECT name FROM sqlite_master WHERE type='table' AND name='#{tbl}'")
        end

        def tables
          @db.execute("SELECT name FROM sqlite_master WHERE type='table'")
        end

      end # class::Sqlite < Connection
    end # class::Connection
  end # module::Model
end # module::GemVault
