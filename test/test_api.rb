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

    it "forced default" do
      get_detect :_forced => true

      assert last_response.ok?

      last_response.body.wont_be_empty
      last_response.body.must_include 'Unknown'
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

  describe "with unknown user-agent" do
    before do
      header 'User-Agent', 'curl/7.21.6 (x86_64-pc-linux-gnu)'
    end

    it "is empty for default" do
      get_detect

      assert last_response.ok?
      last_response.body.must_be_empty
    end

    it "forced default" do
      get_detect :_forced => true

      assert last_response.ok?

      last_response.body.wont_be_empty
      last_response.body.must_include 'Unknown'
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

      body['string'].must_include 'curl'
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

    it "forced default" do
      get_detect :_forced => true

      assert last_response.ok?

      last_response.body.wont_be_empty
      last_response.body.must_include 'Unknown'
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

    it "forced default" do
      get_detect :_forced => true

      assert last_response.ok?

      last_response.body.wont_be_empty
      last_response.body.must_include 'Microsoft Internet Explorer'
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

  describe "information page" do
    it "renders on no param" do
      get '/'
      assert last_response.ok?
    end

    it "renders with just for param" do
      get '/', :for => ''
      assert last_response.ok?
    end

    it "renders with just version param" do
      get '/', :version => ''
      assert last_response.ok?
    end

    it "redirects on empty for param" do
      get '/', :for => '', :version => '1.0.0'
      assert last_response.redirect?
    end

    it "redirects on bad for param" do
      get '/', :for => 'blah', :version => '1.0.0'
      assert last_response.redirect?
    end

    it "redirects on empty version param" do
      get '/', :for => 'msie', :version => ''
      assert last_response.redirect?
    end

    it "works for msie" do
      get '/', :for => :msie, :version => '6.0'

      assert last_response.ok?

      last_response.body.must_include 'Internet Explorer'
      last_response.body.must_include 'http://www.microsoft.com'
    end

    it "works for firefox" do
      get '/', :for => :firefox, :version => '3.5'

      assert last_response.ok?

      last_response.body.must_include 'Firefox'
      last_response.body.must_include 'http://www.mozilla.org/'
    end

    it "works for chrome" do
      get '/', :for => :chrome, :version => '4.0'

      assert last_response.ok?

      last_response.body.must_include 'Chrome'
      last_response.body.must_include 'http://www.google.com/'
    end

    it "works for safari" do
      get '/', :for => :safari, :version => '3.0'

      assert last_response.ok?

      last_response.body.must_include 'Safari'
      last_response.body.must_include 'http://www.apple.com/'
    end

    it "works for opera" do
      get '/', :for => :opera, :version => '9.50'

      assert last_response.ok?

      last_response.body.must_include 'Opera'
      last_response.body.must_include 'http://www.opera.com/'
    end

    it "without referrer" do
      get '/', :for => :msie, :version => '6.0'

      assert last_response.ok?

      last_response.body.must_include 'window.history.back()'
    end

    it "with referrer" do
      header 'Referer', 'http://www.testreferer.com'
      get '/', :for => :msie, :version => '6.0'

      assert last_response.ok?

      last_response.body.must_include 'http://www.testreferer.com'
    end

    it "works for unknown" do
      get '/', :for => :u, :version => '0'

      assert last_response.ok?

      last_response.body.wont_be_empty
    end
  end
end
