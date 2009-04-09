module TwitterDispatch
  class Dispatcher
    # Override this method to provide new defaults.
    # The defaults are as follows:
    #
    # * <tt>:base_url</tt> - http://twitter.com
    #
    def self.default_options
      {
        :base_url => 'http://twitter.com',
        :api_timeout => 10
      }
    end

    # Initialize a dispatcher using the specified strategy. 
    #
    # *Strategies*
    #
    # * <tt>:oauth</tt> - You will need to provide four arguments before any options: the consumer key, the consumer secret, the access key, and the access secret.
    # * <tt>:basic</tt> - You will need to provide two arguments before any options: the screen name# and the password of the authenticating user.
    # * <tt>:none</tt> - You will not need to provide any additional arguments but will only be able to access resources that do not require authentication (such as <tt>statuses/public_timeline</tt>).
    #
    # *Options*
    #
    # * <tt>:base_url</tt> - The base URL used to make calls. This way the dispatcher can be used on Twitter-compatible APIs, not just the Twitter API.
    #
    def initialize(strategy = :none, *args)
      args << {} unless args.last.is_a?(Hash)
      @strategy = strategy
      case @strategy
      when :oauth
        raise ArgumentError, "The :oauth strategy requires two or four arguments - consumer_key, consumer_secret, access_key and access_secret." unless [3,5].include?(args.size)
        if args.size == 5
          @consumer_key, @consumer_secret, @access_key, @access_secret, @options = *args
        else
          @consumer_key, @consumer_secret, @options = *args
        end
      when :basic
        raise ArgumentError, "The :basic strategy requires two arguments - screen_name and password." unless args.size == 3
        @screen_name, @password, @options = *args
      when :none
        raise ArgumentError, "The :none strategy does not take any mandatory arguments, only options." unless args.size == 1
        @options = *args
      else
        raise ArgumentError, "Valid strategies are :oauth, :basic and :none."
      end

      @options = TwitterDispatch::Dispatcher.default_options.merge(@options)
    end

    # Generates an OAuth consumer for this dispatcher given the
    # base_url and provided access key and token.
    def consumer
      OAuth::Consumer.new(@consumer_key, @consumer_secret, :site => @options[:base_url])
    end

    #:nodoc:
    def path_prefix
      URI.parse(base_url).path
    end

    def net
      uri = URI.parse(base_url)
      net = Net::HTTP.new(uri.host, uri.port)
      net.use_ssl = uri.scheme == 'https'
      net.read_timeout = @options[:api_timeout]
      net
    end

    attr_reader :access_token, :access_secret, :strategy, :screen_name, :password

    def base_url
      @options[:base_url]
    end
    
    # Returns true if a strategy is set.
    def strategy?
      strategy != :none
    end

    # True if the current strategy is OAuth.
    def oauth?
      strategy == :oauth
    end

    # True if the current strategy is HTTP Basic.
    def basic?
      strategy == :basic
    end
    
    def proxy
      case strategy
      when :oauth
        @proxy ||= TwitterDispatch::Proxy::OAuth.new(self)
      when :basic
        @proxy ||= TwitterDispatch::Proxy::Basic.new(self)
      when :none
        @proxy ||= TwitterDispatch::Proxy::None.new(self)
      end     
    end

    # Make a request through the dispatcher. Method
    # can be any of the standard HTTP verbs, path
    # is the API path such as <tt>/account/verify_credentials.json</tt>
    def request(http_method, path, *args)
      proxy.request(http_method, path, *args)
    end

    # Perform a GET request through the dispatcher.
    def get(*args)
      proxy.get(*args)
    end

    # Perform a POST request through the dispatcher.
    def post(*args)
      proxy.post(*args)
    end

    # Perform a PUT request through the dispatcher.
    def put(*args)
      proxy.put(*args)
    end

    # Perform a DELETE request through the dispatcher.
    def delete(*args)
      proxy.delete(*args)
    end
  end
end
