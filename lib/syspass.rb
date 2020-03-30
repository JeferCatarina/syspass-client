require 'json'
require 'net/http'
require 'net/https'
require 'uri'

class Syspass
    class Method
        @@json_rcp_version = '2.0'
        @@json_rcp_request_id = 1
        @@headers = { 'Content-Type' => 'application/json-rpc' }

        def initialize(prefix, connection)
            @prefix = prefix
            @connection = connection
        end

        def method_missing(method_name, *args)
            validate_args(args)
            method  = "#{@prefix}/#{method_name}"
            params  = args[0] || {}

            query(method, @connection.options, params)
        end

        def query(method, options, params)
            jsonquery = {
                :jsonrpc    => @@json_rcp_version,
                :method     => method,
                :params     => params.merge!(options),
                :id         => @@json_rcp_request_id,
            }
            sslmode = @connection.url.scheme == 'https' 
            http = Net::HTTP.new(@connection.url.host, @connection.url.port)

            if sslmode
                http.use_ssl = sslmode
                http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            end

            request = Net::HTTP::Post.new(@connection.url.path, @@headers)
            request.body = jsonquery.to_json
            response = http.request(request)
            json_response = JSON.parse(response.body)

            if json_response['error']
                raise "error handling: #{json_response['error']}"
            end
            json_response['result']
        end

        def validate_args(args)
            unless args.is_a?(Array)
                raise TypeError, "Wrong argument:  #{args.inspect} (expected an Array)"
            end
        end
    end

    attr_reader :url, :options

    def initialize(url, options = {})
        validate_options(options)
        @url = URI.parse(url)
        @options = options
    end

    def validate_options(options)
        unless options.key?(:authToken)
            raise ArgumentError, "Expected :authToken in options. Got: #{options.inspect}"
        end
        unless options.key?(:tokenPass)
            warn("WARNING: Some queries require :tokenPass and you didn't set it.")
        end
    end

    def method_missing(method_name)
        Syspass::Method.new(method_name, self)
    end
end
