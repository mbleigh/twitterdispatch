require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterDispatch::Proxy::Basic do
  before do
    @dispatcher = TwitterDispatch.new(:basic, 'abc', 'def')
  end

  it 'should store the dispatcher in an attr_accessor' do
    TwitterDispatch::Proxy::Basic.new(@dispatcher).dispatcher.should == @dispatcher
  end

  describe '#request' do
    before do
      @proxy = TwitterDispatch::Proxy::Basic.new(@dispatcher)
      FakeWeb.register_uri('http://twitter.com:80/fake.json', :string => {'fake' => true}.to_json)
        FakeWeb.register_uri('http://twitter.com:80/fake.xml', :string => '<fake>true</fake>')
    end
    
    it 'should automatically parse JSON if valid' do
       @proxy.request(:get, '/fake.json').should == {'fake' => true}
    end

    it 'should return XML as a string' do
      @proxy.request(:get, '/fake.xml').should == "<fake>true</fake>"
    end

    it 'should append .json to the path if no extension is provided' do
      @proxy.request(:get, '/fake.json').should == @proxy.request(:get, '/fake')
    end

    %w(get post put delete).each do |method|
      it "should build a #{method} class based on a :#{method} http_method" do
        @req = eval("Net::HTTP::#{method.capitalize}").new('/fake.json')
        eval("Net::HTTP::#{method.capitalize}").should_receive(:new).and_return(@req)
        @proxy.request(method.to_sym, '/fake')
      end
    end

    it 'should start the HTTP session' do
      @net = @dispatcher.net
      @dispatcher.stub!(:net).and_return(@net)
      @net.should_receive(:start)
      lambda{@proxy.request(:get, '/fake')}.should raise_error(NoMethodError)
    end

    it "should raise a TwitterDispatch::HTTPError if response code isn't 200" do
      FakeWeb.register_uri('http://twitter.com:80/bad_response.json', :string => {'error' => 'bad response'}.to_json, :status => ['401', 'Unauthorized'])
      lambda{@proxy.request(:get, '/bad_response')}.should raise_error(TwitterDispatch::HTTPError)
    end

    it 'should set the error message to the JSON message' do
      FakeWeb.register_uri('http://twitter.com:80/bad_response.json', :string => {'error' => 'bad response'}.to_json, :status => ['403', 'Forbidden'])
      lambda{@proxy.request(:get, '/bad_response')}.should raise_error(TwitterDispatch::HTTPError, 'bad response')
    end

    it 'should raise a TwitterDispatch::Proxy::Unauthorized on 401' do
      FakeWeb.register_uri('http://twitter.com:80/unauthenticated_response.xml', :string => "<hash>\n<request>/unauthenticated_response.xml</request>\n<error>bad response</error>\n</hash>", :status => ['401', 'Unauthorized'])
      lambda{@proxy.request(:get, '/unauthenticated_response.xml')}.should raise_error(TwitterDispatch::Unauthorized)
    end

    it 'should set the error message to the XML message' do
      FakeWeb.register_uri('http://twitter.com:80/bad_response.xml', :string => "<hash>\n<request>/bad_response.xml</request>\n<error>bad response</error>\n</hash>", :status => ['403', 'Forbidden'])
      lambda{@proxy.request(:get, '/bad_response')}.should raise_error(TwitterDispatch::HTTPError, 'bad response')
    end
  end

  %w(get post delete put).each do |method|
    it "should have a ##{method} method that calls request(:#{method})" do
      dispatcher = TwitterDispatch::Proxy::Basic.new(@user)
      if %w(get delete).include?(method)
        dispatcher.should_receive(:request).with(method.to_sym, '/fake.json')
      else
        dispatcher.should_receive(:request).with(method.to_sym, '/fake.json', '')
      end
      dispatcher.send(method, '/fake.json')
    end
  end
end

