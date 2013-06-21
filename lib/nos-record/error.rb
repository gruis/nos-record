module NosRecord
  module Error; end
  class ModelError < ::StandardError
    include Error
  end
  class IdRequired < ModelError; end
  class ConnectionRequired < ModelError; end
end # module::NosRecord
