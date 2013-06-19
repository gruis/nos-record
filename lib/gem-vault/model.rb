require "gem-vault/model/connection"
require "gem-vault/model/search"

module GemVault
  module Model

    class << self
      def models
        @models ||= []
      end

      def included(c)
        Model.models << c
        c.extend(Enumerable)
        c.instance_eval do
          attr_writer :default_connection

          def default_connection
            @default_connection || Model.default_connection
          end

          def get(id, connection = nil)
            connection ||= Model.default_connection
            connection.get(id, self)
          end

          def each(connection = nil, &blk)
            connection ||= Model.default_connection
            connection.each(self).each(&blk)
          end

          def find_by_attr(attr, val)
            each.select {|o| o.instance_variable_get(:"@#{attr}") == val }
          end
        end
      end

      def default_connection=(c)
        @default_connection = c
      end

      def default_connection
        @default_connection ||= Connection.new
      end
    end

    def save(connection = nil)
      con = my_connection(connection)
      begin
        filtered = filter_before_save
        con.save(self)
      ensure
        restore_filtered(filtered)
      end
      self
    end

    def delete(connection = nil)
      con = my_connection(connection)
      con.delete(self)
      self
    end

    private

    def my_connection(connection = nil)
      connection ||
        @_connection ||
        self.class.default_connection ||
        Model.default_connection
    end

    def never_serialize
      [:@_connection]
    end

    def filter_before_save
      filtered = never_serialize
        .select{|i| instance_variable_defined?(i) }
        .map{|i| remove_instance_variable(i) }
      Hash[ never_serialize.zip(filtered) ]
    end

    def restore_filtered(eles)
      eles.each {|k,v| instance_variable_set(k, v) }
    end

  end # module::Model
end # module::GemVault
