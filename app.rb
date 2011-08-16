require 'sinatra/base'

class BadBrowser < Sinatra::Base
  configure do
    set :logging, true
    set :static, false # we'll use nginx to serve our page and such
  end

  helpers do
    def user_agent agent
      @user_agent ||= UserAgent.new agent
    end
  end

  before do
    user_agent request.user_agent
  end

  get "/detect.js" do
    content_type :js
    render :erb, :'result.js'
  end
  
  get "/" do # more for debug purposes
    redirect '/detect.js'
  end
end