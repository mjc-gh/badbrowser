require 'bad_browser/user_agent'

class BadBrowser < Sinatra::Base
  SHORT_NAMES = { :redirect => :rd, :callback => :cb, :link => :lk }
  
  configure do
    Tilt.register 'js', Tilt::ERBTemplate
    
    dir = File.dirname(File.expand_path(__FILE__))
    
    set :views, "#{dir}/views"
    set :public_folder, "#{dir}/public"
    set :static, true
    
    set :base_url, ENV['RACK_ENV'] == 'production' ? 'http://badbrowser.info' : 'http://localhost:4567'
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
    def default_info_link; "#{settings.base_url}/"; end
    
    ##
    # helpers for user_agent 
    def user_agent; @user_agent; end    
    def browser; user_agent.browser; end
    def version; user_agent.version; end
    def string; user_agent.string; end
    
    ##
    # Get human friendly name for browser
    def browser_name
      symbol = user_agent ? browser : params[:for].to_sym

      case symbol
      when :msie then 'Microsoft Internet Explorer'
      when :firefox then 'Mozilla Firefox'
      when :chrome then 'Google Chrome'
      when :safari then 'Apple Safari'      
      else symbol.capitalize
      end
    end
    
    ##
    # Get update URL for respective browser
    def update_url
      case params[:for].to_sym
      when :msie then "http://www.microsoft.com/ie"
      when :firefox then "http://www.mozilla.org/firefox"
      when :chrome then "http://www.google.com/chrome"
      when :safari then "http://www.apple.com/safari"
      when :opera then "http://www.opera.com/"
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
    callback || !result || params[:_forced] ? render(:haml, :'detect.js', :layout => false, :locals => { :result => result }) : ''
  end


  ##
  # Static Routes
  get '/' do
    if params[:for].nil? || params[:version].nil?
      haml :'pages/home'
    else
      if !params[:version].empty? && UserAgent::BROWSERS.include?(params[:for])
        haml :'pages/info'
      else
        redirect '/'
      end
    end
  end

  get '/docs' do; haml :'pages/docs'; end
  get '/faq' do; haml :'pages/faq'; end
  get '/news' do; haml :'pages/news'; end
  get '/demo' do; haml :'pages/demo'; end
  get '/info' do; haml :'pages/info'; end

end