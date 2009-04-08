require 'rubygems'
require 'oauth'
require 'json'

module TwitterDispatch
  def self.new(*args)
    TwitterDispatch::Dispatcher.new(*args)
  end

  class HTTPError < StandardError; end
  class Unauthorized < HTTPError; end
end

require 'twitter_dispatch/dispatcher'
require 'twitter_dispatch/proxy/shared'
require 'twitter_dispatch/proxy/oauth'
require 'twitter_dispatch/proxy/basic'
require 'twitter_dispatch/proxy/none'
