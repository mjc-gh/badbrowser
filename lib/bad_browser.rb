require 'bad_browser/user_agent'

class BadBrowser < Sinatra::Base
  SHORT_NAMES = { :redirect => :rd, :callback => :cb, :link => :lk }
  
  configure do
    dir = File.dirname(File.expand_path(__FILE__))
    
    set :views, "#{dir}/views"
    set :public_folder, "#{dir}/public"
    set :static, true
  end

  helpers do
    ##
    # Outputs some logging details; defaults to stdout via puts
    def log_request(result)
      msg = [result, request.ip, request.referer || 'N/A', string]
      msg.map! { |val| %Q("#{val}") }
            
      puts msg.join(', ')
    end
    
    ##
    # helpers for Javascript generation; parameters that are used more than
    # once (like in an if statement) will usually have their own helper
    def read_param(key)
      return nil unless value = params[key] || params[SHORT_NAMES[key]]
      value.strip!
      
      value.empty? ? nil : value
    end
    
    def redirect_to; @redirect_to ||= read_param(:redirect); end
    def callback; @callback ||= read_param(:callback); end

    ##
    # helpers for user_agent 
    def user_agent; @user_agent; end
    def browser; user_agent.browser; end
    def version; user_agent.version; end
    def string; user_agent.string; end

    ##
    # Get human friendly name for browser
    def browser_name
      case browser
      when :msie then 'Internet Explorer'
      else browser.capitalize
      end
    end
    
    ##
    # determines if the parsed version is acceptable or not
    def compare_versions
      return true unless version
      
      case browser
      when :msie then version >= '7.0'
      when :firefox then version >= '3.6.22'
      when :chrome then version >= '4.1.249'
      when :safari then version >= '4.0'
      when :opera then version >= '9.0'
      else true # return true if we don't know
      end
    end
  end
  
  ##
  # We put this in a before to ensure its run first. Likewise, we may add more routes in the future
  before '/detect.js' do
    @user_agent ||= UserAgent.new(request.user_agent)
  end
  
  ##
  # Core API route
  get '/detect.js' do
    result = compare_versions
    log_request result
    
    content_type :js
    callback || !result ? render(:haml, :'detect.js', :layout => false, :locals => { :result => result }) : ''
  end


  ##
  # Static Routes
  get '/' do; haml :'pages/home'; end
  get '/docs' do; haml :'pages/docs'; end
  get '/faq' do; haml :'pages/faq'; end
  get '/news' do; haml :'pages/news'; end

end