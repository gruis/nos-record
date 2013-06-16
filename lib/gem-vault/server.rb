require "gem-vault/server/error"

module GemVault
  module Server
    class << self
      # The parent directory for the 'gems' directory
      attr_writer :rootdir

      def rootdir
        @rootdir ||= File.expand_path("var")
      end

      def gemdir
        @gemdir ||= File.join(rootdir, "gems")
      end
    end # class << self
  end # module::Server
end # module::GemVault
