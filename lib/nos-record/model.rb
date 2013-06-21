module NosRecord
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
            return connection.get(id, self) if !id.is_a?(Hash)
            filters = id
            filter  = filters.shift
            objs    = find_by_attr(*filter)
            return objs[0] if filter[0] == :id
            return objs if filters.empty?
            attrs[1..-1].inject(objs) do |memo, (attr, val)|
              memo.select{|o| o.instance_variable_get(:"@#{attr}") == val }
            end
          end

          def each(connection = nil, &blk)
            connection ||= Model.default_connection
            connection.each(self).each(&blk)
          end

          def find_by_attr(attr, val, connection = nil)
            each(connection).select {|o| o.instance_variable_get(:"@#{attr}") == val }
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

    attr_reader :_connection

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
end # module::NosRecord
