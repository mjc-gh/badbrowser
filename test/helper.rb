gem "minitest"
require 'minitest/autorun'
require 'minitest/benchmark'
require 'purdytest'
require 'yaml'


$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'app'
require 'lib/user_agent.rb'


def fixture name
  YAML.load( File.open(File.join('test', 'fixtures', "#{name}.yml"), 'r+').read )
end

def user_agent_fixtures
  Hash[Dir['test/fixtures/user_agents/*.yml'].collect! { |fname|
    [fname.match(/\w+\.yml/).to_s, YAML.load( File.open(fname, 'r+').read )]
  }]
end

def user_agent str
  AgentDetector.new str
end