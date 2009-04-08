require 'net/http'

module TwitterDispatch 
  module Proxy
    class Basic
      include TwitterDispatch::Proxy::Shared

      attr_accessor :dispatcher

      def initialize(dispatcher)
        self.dispatcher = dispatcher
      end

      def request(http_method, path, body=nil, *arguments)
        path = dispatcher.path_prefix + path
        path = append_extension_to(path)

        response = dispatcher.net.start{ |http|
          req = eval("Net::HTTP::#{http_method.to_s.capitalize}").new(path, *arguments)
          req.basic_auth dispatcher.screen_name, dispatcher.password if dispatcher.basic?
          req.set_form_data(body) unless body.nil?
          http.request(req)
        }
        
        handle_response(response)      
      end

      def get(path, *arguments)
        request(:get, path, *arguments)
      end

      def post(path, body='', *arguments)
        request(:post, path, body, *arguments)
      end

      def put(path, body='', *arguments)
        request(:put, path, body, *arguments)
      end

      def delete(path, *arguments)
        request(:delete, path, *arguments)
      end
    end
  end
end

