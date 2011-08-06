require 'sinatra/base'
require './lib/user_agent'

class BadBrowser < Sinatra::Base
  configure do
    set :logging, true
    set :static, false # we'll use nginx to serve our page and such
    
    register Sinatra::UserAgent
  end

  before do
    puts request.user_agent
  end

  get "/detect.js" do
    content_type :js
    render :erb, :'result.js'
  end
  
  get "/" do # more for debug purposes
    redirect '/detect.js'
  end
end