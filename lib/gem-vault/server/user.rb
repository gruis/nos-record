require "gem-vault/model"

module GemVault
  module Server
    class User
      include Model

      attr_accessor :id
      attr_accessor :uid
      attr_accessor :first_name
      attr_accessor :last_name
      attr_accessor :email
      attr_reader :created_on

      def initialize(attrs = {})
        attrs.each {|k,v| instance_variable_set(:"@#{k}", v) }
        @created_on = Time.new
      end

      def api_key
        return @api_key if @api_key
        return nil unless @api_key_id
        raise "Connection required" unless @_connection
        @_connection.get(@api_key_id)
      end

      def gen_api_key
        api_key.delete if api_key
        @api_key    = ApiKey.new(self).save
        @api_key_id = @api_key.id
        self
      end

    end # class:User
  end # module::Server
end # module::GemVault

require "gem-vault/server/api-key"
