require "gem-vault/model"
require "securerandom"

module GemVault
  module Server
    class ApiKey
      include Model

      attr_reader :id
      alias :key :id

      attr_reader :created_on

      def initialize(user)
        @created_on   = Time.new
        @key          = SecureRandom.hex
        @user         = user
        @user_id      = user.id
      end

      def user
        return @user if @user
        return nil unless @user_id
        raise "Connection required" unless @_connection
        @_connection.get(@user_id)
      end

      def user=(u)
        @user_id = u.id if u.is_a?(User)
        @user    = u
      end

      private

      def never_serialize
        super | [:@user]
      end

    end # class:ApiKey
  end # module::Server
end # module::GemVault

require "gem-vault/server/user"

