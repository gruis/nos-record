module GemVault
  module Model
    module Search
      include Enumerable

      def get(id, connection = nil)
        connection ||= Connection.new
        connection.get(id)
      end

      def each(connection = nil, &blk)
        connection ||= Connection.new
        connection.each(self).each(&blk)
      end

      def find_by_attr(attr, val)
        each.select {|o| o.instance_variable_get(:"@#{attr}") == val }
      end
    end # module::Search
  end # module::Model
end # module::GemVault
