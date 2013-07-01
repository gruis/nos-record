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

      def status
        normalize_aaresults(rpc("status"))
      end

      def report
        normalize_aaresults(rpc("report"))
      end

      def echo(val)
        rpc("echo", val => "").keys.first
      end

      def increment(key, num = 1)
        rpc("increment", 'key' => key, 'num' => num)["num"].first.to_i
      end

      def include?(key)
        rpc_request('check', 'key' => key).code == 200
      end

      protected

      def rest_key(k)
        "/#{URI.encode(k)}"
      end

      def retrv(key)
        res = rest_request('GET', rest_key(key))
        res.code != 200 ? nil : res.body
      end

      def store(key, val)
        resp = rest_request('PUT', rest_key(key), val)
        unless resp.code == 201
          raise("set error '#{key}': #{resp.body}")
        end
        self
      end

      def unstore(key)
        res = rest_request('DELETE', rest_key(key))
        res.code == 204
      end

      def values(klass = nil)
        unless klass.nil?
          recs = get_bulk(match_prefix(key_for_class(klass)))
          return recs ? recs.values : []
        end
        get_bulk(match_prefix("")).each_value
      end

      private

      Response  = Struct.new(:code, :content_type, :body)
      RPC_TMPL = "POST %s HTTP/1.1\r\nContent-Length: %d\r\nContent-Type: text/tab-separated-values; colenc=%s\r\n\r\n%s"
      REST_TMPL = "%s %s HTTP/1.1\r\nContent-Length: %d\r\n\r\n%s"
      GET_TMPL  = "GET %s HTTP/1.1\r\n\r\n"

      def close_store
        @db.close
      end

      def open_store
        sock = ::TCPSocket.new(@url.host, @url.port)
      end


      def match_prefix(prefix)
        data = rpc("match_prefix", {:prefix => prefix})
        num = data.delete('num')
        data.keys.map{|k| k[1..-1] }
      end

      def get_bulk(keys)
        data = rpc('get_bulk', Hash[keys.map{|k| ["_#{k}"] }])
        data.delete("num")
        Hash[data.map{|k,vs| [k[1..-1], vs[0]] }]
      end


      def rest_request(meth, path, params = "")
        if meth == 'GET'
          if !params.empty?
            path = "#{path}?#{params.map{|k,v| "#{k}=#{v}"}.join("&")}"
          end
          request = GET_TMPL % [path]
        else
          request = REST_TMPL % [meth, path, params.bytesize, params]
        end
        @db.write(request)
        return rpc_response
      end

      def rpc(meth, params = {})
        decode_response(rpc_request(meth, params))
      end

      def rpc_request(meth, params = {})
        query   = encode_params(params)
        request = RPC_TMPL % ["/rpc/#{meth}", query.bytesize, "B", query]
        @db.write(request)
        rpc_response
      end

      def rpc_response
        status       = @db.gets[9, 3]
        bodylen      = 0
        body         = ""
        content_type = ""
        while (line = @db.gets)
          if line[0..13] == 'Content-Type: '
            content_type = line[14..-1].chomp
            next
          end
          if line[0..15] == 'Content-Length: '
            bodylen = line[16..-1].chomp.to_i
            next
          end
          break if line == "\r\n"
        end
        Response.new(status.to_i, content_type, @db.read(bodylen))
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

      def normalize_aaresults(data)
        Hash[data.map{|k,vs| [k, vs[0]] }]
      end

    end # class::KyotoCabinet < Connection
  end # class::Connection
end # module::NosRecord
