require 'bundler'
Bundler.require :default, :test
require 'minitest/benchmark'


require 'bad_browser'

def fixture name
  YAML.load( File.open(File.join('test', 'fixtures', "#{name}.yml"), 'r+').read )
end

def user_agent_fixtures
  Hash[Dir['test/fixtures/user_agents/*.yml'].map! { |fname|
    [fname.match(/\w+\.yml/).to_s, YAML.load( File.open(fname, 'r+').read )]
  }]
end

def user_agent str
  UserAgent.new str
end

def browser_version str
  BrowserVersion.new str
end