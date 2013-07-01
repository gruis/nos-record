require 'uri'
require 'net/http'
module NosRecord
  class Connection
    class KyotoTycoon < Connection

      TIMEOUT = 30
      URL     = "http://localhost:1978/?timeout=#{TIMEOUT}"
      attr_reader :url

      def initialize(url = URL)
        @url     = URI.parse(url)
        @opts    = @url.query && Hash[@url.query.split("&").map{|p| p.split("=") }]
        @opts    ||= {}
        @timeout = @opts["timeout"]
        @timeout &&= @timeout.to_i
        @timeout ||= 30
        # TODO support custom db
        self.open
      end


      protected

      def rest_key(k)
        "/#{URI.encode(k)}"
      end

      def retrv(key)
        res = @db.request(Net::HTTP::Get::new(rest_key(key)))
        res.code.to_i != 200 ? nil : res.body
      end

      def store(key, val)
        unless @db.request(Net::HTTP::Put.new(rest_key(key)), val).code.to_i == 201
          raise("set error '#{key}': #{db.error}")
        end
        self
      end

      def unstore(key)
        res = @db.request(Net::HTTP::Delete::new(rest_key(key)))
        res.code.to_i == 204
      end

      def values(klass = nil)
        unless klass.nil?
          recs = get_bulk(match_prefix(key_for_class(klass)))
          return recs ? recs.values : []
        end
        get_bulk(match_prefix("")).each_value
      end

      private

      def close_store
        @db.finish
      end

      def open_store
        ua = Net::HTTP.new(@url.host, @url.port)
        ua.read_timeout = @timeout
        ua.start
        ua
      end


      def match_prefix(prefix)
        data = rpc_request("match_prefix", {:prefix => prefix})
        num = data.delete('num')
        data.keys.map{|k| k[1..-1] }
      end

      def get_bulk(keys)
        data = rpc_request('get_bulk', Hash[keys.map{|k| ["_#{k}"] }])
        data.delete("num")
        Hash[data.map{|k,vs| [k[1..-1], vs[0]] }]
      end


      def rpc_get_request(meth, params = {})
        qs = params.map{|k,v| "#{k}=#{v}"}.join("&")
        req = Net::HTTP::Get.new("/rpc/#{meth}?#{qs}")
        res = @db.request(req)
        raise res.body unless [200, 450].include?(res.code.to_i)
        decode_response(res)
      end

      def rpc_request(meth, params = {})
        req = Net::HTTP::Post.new("/rpc/#{meth}")
        req.content_type = "text/tab-separated-values; colenc=B"
        req.body = encode_params(params)
        res = @db.request(req)
        raise res.body unless [200, 450].include?(res.code.to_i)
        decode_response(res)
      end

      def encode_params(params)
        params.inject([]) do |body, cols|
          body << (cols.map { |v| [v.to_s].pack("m")[0..-2] }.join("\t"))
          body
        end.join("\r\n")
      end

      def decode_response(res)
        if res.content_type.nil? || (idx = res.content_type.index("colenc=")).nil?
          decoded = decode_n_body(res.body.each_line)
        else
          decoded = case (enc = res.content_type[idx + 7 .. idx + 8])
            when "U"
              decode_u_body(res.body.each_line)
            when "B"
              decode_b_body(res.body.each_line)
            when "Q"
              decode_q_body(res.body.each_line)
            else
              raise "Unrecognized encoding type: #{enc}"
            end
        end
        Hash[decoded]
      end

      def decode_b_body(lines)
        lines.map do |line|
          key, *rest = line.chomp.split("\t")
          [key.unpack("m").first, rest.map{|r| r.unpack("m").first}]
        end
      end

      def decode_u_body(lines)
        lines.map do |line|
          key, *rest = line.chomp.split("\t")
          [CGI.unescape(key), rest.map{|r| CGI.unescape(r) }]
        end
      end

      def decode_q_body(lines)
        raise NotImplementedError
      end

      def decode_n_body(lines)
        lines.map do |line|
          key, *rest = line.chomp.split("\t")
          [key, rest]
        end
      end

    end # class::KyotoCabinet < Connection
  end # class::Connection
end # module::NosRecord
