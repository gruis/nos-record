module NosRecord
  module Model
    module HideIdAttrs
      def to_hash
        h = super
        h.keys.each do |k|
          if k[-3..-1] == "_id"
            h[k[0...-3]] = h.delete(k)
          elsif k[-4..-1] == "_ids"
            h[k[0...-4]+'s'] = h.delete(k)
          end
        end
        h
      end
    end # module::HideIdAttrs
  end # module::Model
end # module::NosRecord

