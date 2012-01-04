# BadBrowser API

Welcome to the BadBrowser Core API. 

Hosted on Heroku: http://badbrowser.herokuapp.com

## INSTALL

#### Install Ruby

I would highly recommend RVM: http://beginrescueend.com/

If you use RVM, do *not* use root. To install Ruby 1.9.2 run the following:

    rvm install 1.9.2

#### Install Gems

We use bundler (because it's awesome)

So first install bundler via: 

    gem install bundler

Then run the following and all the gems needed will be installed

    bundle install

## DEVELOPING

It is recommend you use "shotgun" to locally run the application. To install shotgun, run:

    gem install shotgun
	
To start the application, run: 

    shotgun config.ru

## TESTING

To run the test simply run the following: 

    rake test
	
To skip a Browser user-agent test, provide a SKIP argument

    rake test SKIP=opera,safari