require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterDispatch::Proxy::OAuth do
  describe '#request' do
    before do
      @dispatcher = TwitterDispatch.new(:oauth, 'abc', 'def', 'hgi', 'jkl')
      @proxy = TwitterDispatch::Proxy::OAuth.new(@dispatcher)
      FakeWeb.register_uri(:get, 'http://twitter.com:80/fake.json', :string => {'fake' => true}.to_json)
      FakeWeb.register_uri(:get, 'http://twitter.com:80/fake.xml', :string => "<fake>true</fake>")
    end
    
    it 'should automatically parse json' do
      result = @proxy.request(:get, '/fake.json')
      result.should be_a(Hash)
      result['fake'].should be_true
    end

    it 'should return xml as a string' do
      @proxy.request(:get, '/fake.xml').should == '<fake>true</fake>'
    end

    it 'should append .json to the path if no extension is provided' do
      @proxy.request(:get, '/fake').should == @proxy.request(:get, '/fake.json')
    end

    it "should raise a TwitterDispatch::HTTPError if response code isn't 200" do
      FakeWeb.register_uri('http://twitter.com:80/bad_response.json', :string => {'error' => 'bad response'}.to_json, :status => ['401', 'Unauthorized'])
      lambda{@proxy.request(:get, '/bad_response')}.should raise_error(TwitterDispatch::HTTPError)
    end

    it 'should set the error message to the JSON message' do
      FakeWeb.register_uri('http://twitter.com:80/bad_response.json', :string => {'error' => 'bad response'}.to_json, :status => ['403', 'Forbidden'])
      lambda{@proxy.request(:get, '/bad_response')}.should raise_error(TwitterDispatch::HTTPError, 'bad response')
    end

    it 'should set the error message to the XML message' do
      FakeWeb.register_uri('http://twitter.com:80/bad_response.xml', :string => "<hash>\n<request>/bad_response.xml</request>\n<error>bad response</error>\n</hash>", :status => ['403', 'Forbidden'])
      lambda{@proxy.request(:get, '/bad_response.xml')}.should raise_error(TwitterDispatch::HTTPError, 'bad response')
    end

    it 'should still error correctly on a totally messed up response' do
      FakeWeb.register_uri('http://twitter.com:80/bad_response.xml', :string => "aosidnaoisdnasd", :status => ['403', 'Forbidden'])
      lambda{@proxy.request(:get, '/bad_response.xml')}.should raise_error(TwitterDispatch::HTTPError, 'An unknown 403 error occurred processing your API request.')
    end

    it 'should raise a TwitterAuth::Dispatcher::Unauthorized on 401' do
      FakeWeb.register_uri('http://twitter.com:80/unauthenticated_response.xml', :string => "<hash>\n<request>/unauthenticated_response.xml</request>\n<error>bad response</error>\n</hash>", :status => ['401', 'Unauthorized'])
      lambda{@proxy.request(:get, '/unauthenticated_response.xml')}.should raise_error(TwitterDispatch::Unauthorized)
    end

    it 'should work with verb methods' do
      @proxy.get('/fake').should == @proxy.request(:get, '/fake')
    end
  end
end
