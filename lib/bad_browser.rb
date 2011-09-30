require 'bad_browser/user_agent'

class BadBrowser < Sinatra::Base
  SHORT_NAMES = { :redirect => :rd, :callback => :cb, :link => :lk }
  
  configure do
    dir = File.dirname(File.expand_path(__FILE__))
    
    set :views, "#{dir}/views"
    set :logging, true
    set :static, false
  end

  helpers do
    ##
    # helpers for Javascript generation; parameters that are used more than
    # once (like in an if statement) will usually have their own helper
    def read_param(key)
      return nil unless value = params[key] || params[SHORT_NAMES[key]]
      value.strip!
      
      value.empty? ? nil : value
    end
    
    def redirect; @redirect ||= read_param(:redirect); end
    def callback; @callback ||= read_param(:callback); end
    
    ##
    # Get human friendly name for browser
    def browser_name
      case @user_agent.browser
      when :msie then 'Internet Explorer'
      else @user_agent.browser.capitalize
      end
    end
    
    ##
    # helpers for user_agent 
    def browser; @user_agent.browser; end
    def version; @user_agent.version; end
    def string; @user_agent.string; end
    
    ##
    # simple case statement for browser to determine if the version is acceptable
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