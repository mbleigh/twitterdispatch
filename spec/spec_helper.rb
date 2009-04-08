require 'rubygems'
require 'spec'
require 'fakeweb'

FakeWeb.allow_net_connect = false

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'twitterdispatch'

Spec::Runner.configure do |config|
  
end
