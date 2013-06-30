module NosRecord
  module Model
    module EasyAttrs

      def initialize(attrs = {})
        attrs.each do |k,v|
          ek = :"#{k}="
          respond_to?(ek) ?
            send(ek, v) :
            instance_variable_set(:"@#{k}", v)
        end
        super()
      end

    end # module::EasyAttrs
  end # module::Model
end # module::NosRecord
