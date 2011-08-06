module Sinatra
  module UserAgent
    def user_agent
      @user_agent ||= AgentDetector.new(request.user_agent || '')
    end
  end
end

class AgentDetector
  attr_reader :user_agent, :version
  
  def initialize(str)
    @user_agent = str.to_s
    @user_agent.strip!
    
    unless @user_agent.empty?
      detect_user_agent
    else
      @failed = true 
    end
  end
  
  def failed?
    @failed
  end
  
  def good?
    raise Exception.new('implement me')
  end
  
  def bad?
    raise Exception.new('implement me')
  end
  
  def msie?; @msie; end  
  def gecko?; @gecko; end # aka firefox
  def chrome?; @firefox; end
  def safari?; @safari; end
  
  private 
  
  def detect_user_agent
    
  end
end