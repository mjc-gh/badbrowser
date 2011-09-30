require 'bad_browser/user_agent'

class BadBrowser < Sinatra::Base
  configure do
    use Rack::Logger
    
    set :logging, true
    set :static, false
  end

  helpers do
    def browser; @user_agent.browser; end
    def version; @user_agent.version; end
    
    def compare_versions
      case @user_agent.browser
      when :msie then version >= '7.0'
      when :firefox then version >= '3.6.22'
      when :chrome then version >= '4.1.249'
      when :safari then version >= '4.0'
      when :opera then version >= '9.0'
      # else log it
      end
    end
  end

  before do
    @user_agent ||= UserAgent.new request.user_agent
  end

  get "/detect.js" do
    content_type :js

    !compare_versions ? '' : render(:haml, :'detect.js')
  end
  
  get "/" do # more for debug purposes
    redirect '/detect.js'
  end
end