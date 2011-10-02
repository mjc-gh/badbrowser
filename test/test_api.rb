require 'helper'

describe "API" do
  def get_detect(params = {})
    capture_io do
      get '/detect.js', params
    end
  end
  
  def json_body(callback = '?')
    JSON.parse(last_response.body.strip[1 + callback.size..-2])
  end

  describe "with empty user-agent" do
    before do
      header 'User-Agent', ''
    end

    it "is empty for default" do
      get_detect
      
      assert last_response.ok?
      last_response.body.must_be_empty
    end
    
    it "is empty with redirect" do
      get_detect :redirect => 'http://some.url'
      
      assert last_response.ok?
      last_response.body.must_be_empty
    end
    
    it "returns json with callback" do
      get_detect :callback => '?'
      
      assert last_response.ok?
      last_response.body.must_include '?('

      body = json_body
      
      body['bad'].must_be_nil
      body['failed'].must_equal true
      
      body['string'].must_be_empty
      body['browser'].must_be_nil
      body['version'].must_be_nil
    end
  end
  
  describe "matches browser not version" do
    before do
      header 'User-Agent', 'Mozilla/5.0 (compatible; MSIE;)'
    end
    
    it "is empty for default" do
      get_detect
      
      assert last_response.ok?
      last_response.body.must_be_empty
    end
    
    it "is empty with redirect" do
      get_detect :redirect => 'http://some.url'
      
      assert last_response.ok?
      last_response.body.must_be_empty
    end
    
    it "returns json with callback" do
      get_detect :callback => '?'
      
      assert last_response.ok?
      last_response.body.must_include '?('

      body = json_body
      
      body['bad'].must_be_nil
      body['failed'].must_equal true
      
      body['string'].wont_be_empty
      body['browser'].must_equal 'msie'
      body['version'].must_be_nil
    end
  end
  
  describe "matches browser and good version" do
    before do
      # one day, far into the future, IE10.0 will be a bad browser ;)
      header 'User-Agent', 'Mozilla/5.0 (compatible; MSIE 10.0;)'
    end
    
    it "is empty with default" do
      get_detect
      
      assert last_response.ok?
      last_response.body.must_be_empty
    end

    it "is empty with redirect" do
      get_detect :redirect => 'http://some.url'
      
      assert last_response.ok?
      last_response.body.must_be_empty
    end
    
    it "returns json callback" do
      get_detect :callback => '?'
      
      assert last_response.ok?
      last_response.body.must_include '?('

      body = json_body
      
      body['result'].must_equal true
      body['failed'].must_be_nil
      
      body['string'].wont_be_empty
      body['browser'].must_equal 'msie'
      body['version'].must_equal '10.0'
    end
  end
  
  describe "matches is bad browser" do
    before do
      header 'User-Agent', 'Mozilla/5.0 (compatible; MSIE 6.0;)'
    end
    
    it "is empty with default" do
      get_detect
      
      assert last_response.ok?
      last_response.body.wont_be_empty
    end

    it "is empty with redirect" do
      get_detect :redirect => 'http://some.url'
      
      assert last_response.ok?
      last_response.body.must_match %r(window.location = 'http://some.url')
    end
    
    it "returns json callback" do
      get_detect :callback => '?'
      
      assert last_response.ok?
      last_response.body.must_include '?('

      body = json_body
      
      body['result'].must_equal false
      body['failed'].must_be_nil
      
      body['string'].wont_be_empty
      body['browser'].must_equal 'msie'
      body['version'].must_equal '6.0'
    end
  end
end