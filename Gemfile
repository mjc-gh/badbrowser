source :rubygems

gem 'sinatra'
gem 'haml'
gem 'uglifier'

# for testing stuff
group :test do
  gem 'rack-test', :require => 'rack/test'
  gem 'minitest', :require => 'minitest/autorun'
end

# for on heroku
group :production do
  gem 'thin'
end