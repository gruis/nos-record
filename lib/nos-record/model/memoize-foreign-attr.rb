module NosRecord
  module Model
    module MemoizeForeignAttr

      def memoize(attr, klass)
        iv = :"@#{attr}"
        return instance_variable_get(iv) if instance_variable_defined?(iv)
        id_iv = :"@#{attr}_id"
        return nil unless instance_variable_defined?(id_iv)
        instance_variable_set(iv,
          my_connection.get(instance_variable_get(id_iv), klass)
        )
      end

      def memoize_list(attr, klass)
        raise NotImplemented
      end

    end # module::MemoizeForeignAttr
  end # module::Model
end # module::NosRecord
