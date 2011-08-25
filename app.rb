require 'sinatra/base'

class BadBrowser < Sinatra::Base
  configure do
    set :logging, true
    set :static, false
  end

  before do
    @user_agent ||= UserAgent.new agent
  end

  get "/detect.js" do
    
    
    content_type :js
    render :erb, :'result.js'
  end
  
  get "/" do # more for debug purposes
    redirect '/detect.js'
  end
end