require "bundler/setup"
Bundler.require(:test)

require 'minitest/benchmark'
require 'yaml'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'
require 'user_agent'


def fixture name
  YAML.load( File.open(File.join('test', 'fixtures', "#{name}.yml"), 'r+').read )
end

def user_agent_fixtures
  Hash[Dir['test/fixtures/user_agents/*.yml'].collect! { |fname|
    [fname.match(/\w+\.yml/).to_s, YAML.load( File.open(fname, 'r+').read )]
  }]
end

def user_agent str
  UserAgent.new str
end

def browser_version str
  BrowserVersion.new str
end