module NosRecord
  module Error; end
  class ModelError < ::StandardError
    include Error
  end
  class IdRequired < ModelError; end
  class ConnectionRequired < ModelError; end
  class ServerError < StandardError; end
  class ParseError < ServerError; end
  class RequestError < ServerError; end
  class DataStoreError < ServerError; end
end # module::NosRecord
