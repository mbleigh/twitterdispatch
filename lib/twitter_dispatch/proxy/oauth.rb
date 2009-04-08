module TwitterDispatch
  module Proxy
    class OAuth < OAuth::AccessToken
      include TwitterDispatch::Proxy::Shared

      attr_accessor :dispatcher

      def initialize(dispatcher)
        self.dispatcher = dispatcher
        super(dispatcher.consumer, dispatcher.access_token, dispatcher.access_secret)
      end

      def request(http_method, path, *arguments)
        path = dispatcher.path_prefix + path
        path = append_extension_to(path)

        response = super

        handle_response(response)
      end
    end
  end
end
