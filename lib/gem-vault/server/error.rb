module GemVault
  module Server
    module Error
      class StandardError < ::StandardError
        include Error
      end
    end
  end # module::Server
end # module::GemVault
