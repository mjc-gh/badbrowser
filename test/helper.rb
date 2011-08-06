require 'minitest/autorun'
require 'turn'
require 'yaml'


$:.unshift File.expand_path('..', File.dirname(__FILE__))
require 'app'
require 'lib/user_agent.rb'


def fixture(name)
  YAML.load( File.open(File.join('test', 'fixtures', "#{name}.yml"), 'r+').read )
end

def user_agent(str) 
 AgentDetector.new(str)
end