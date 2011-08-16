gem 'minitest'
require 'minitest/autorun'
require 'minitest/benchmark'
require 'purdytest'
require 'yaml'


path = File.expand_path('..', File.dirname(__FILE__))
require File.join path, 'app'
require File.join path, 'lib/user_agent.rb'


def fixture name
  YAML.load( File.open(File.join('test', 'fixtures', '#{name}.yml'), 'r+').read )
end

def user_agent_fixtures
  Hash[Dir['test/fixtures/user_agents/*.yml'].collect! { |fname|
    [fname.match(/\w+\.yml/).to_s, YAML.load( File.open(fname, 'r+').read )]
  }]
end

def user_agent str
  AgentDetector.new str
end
