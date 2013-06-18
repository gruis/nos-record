require "gem-vault/model/connection"
require "gem-vault/model/search"

module GemVault
  module Model

    def self.models
      @models ||= []
    end

    def self.included(c)
      Model.models << c
    end

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
      return connection unless connection.nil?
      # TODO raise a good error
      raise "Connection required" unless @_connection
      @_connection
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
end # module::GemVault
