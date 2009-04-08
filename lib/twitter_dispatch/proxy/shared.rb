module TwitterDispatch
  module Proxy
    module Shared
      def append_extension_to(path)
        path, query_string = *(path.split("?"))
        path << '.json' unless path.match(/\.(:?xml|json)\z/i)
        "#{path}#{"?#{query_string}" if query_string}"
      end

      def handle_response(response)
        case response
        when Net::HTTPOK 
          begin
            JSON.parse(response.body)
          rescue JSON::ParserError
            response.body
          end
        when Net::HTTPUnauthorized
          raise TwitterDispatch::Unauthorized, 'API Authorization failed. Check user credentials and OAuth consumer permission levels.'
        else
          message = begin
            JSON.parse(response.body)['error']
          rescue JSON::ParserError
            if match = response.body.match(/<error>(.*)<\/error>/)
              match[1]
            else
              "An unknown #{response.code} error occurred processing your API request."
            end
          end

          raise TwitterDispatch::HTTPError, message
        end
      end
    end
  end
end
