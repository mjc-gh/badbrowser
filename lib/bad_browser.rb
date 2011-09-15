require 'sinatra/base'
require 'bad_browser/user_agent'

class BadBrowser < Sinatra::Base
  configure do
    set :logging, true
    set :static, false
  end

  before do
    @user_agent ||= UserAgent.new request.user_agent
    puts request.user_agent.inspect
    puts @user_agent.inspect
  end

  get "/detect.js" do
    content_type :js
    render :erb, :'detect.js'
  end
  
  get "/" do # more for debug purposes
    redirect '/detect.js'
  end
end