module LevelDB
  class DB
    class << self
      def dbs
        @dbs ||= {}
      end

      def open(path, opts = {})
        return @dbs[path] if dbs[path]
        @dbs[path] = public_send(opts.delete(:method) || :new, path, opts)
      end
    end # class << self
  end # class::DB
end # module::DB
