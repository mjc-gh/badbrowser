module Sinatra
  module UserAgent
    def user_agent
      @user_agent ||= AgentDetector.new(request.user_agent || '')
    end
  end
end

class AgentDetector
  attr_reader :user_agent, :version
  
  def initialize str
    @user_agent = str.to_s
    @user_agent.strip!
    @failed = true
    
    detect_user_agent unless @user_agent.empty?
  end
  
  def failed?
    @failed
  end
  
  def msie?; @msie; end
  def firefox?; @firefox; end
  def chrome?; @chrome; end
  def safari?; @safari; end
  def opera?; @opera; end
  
  private 
  
  def detect_user_agent
    if match_for(:msie, /MSIE (\d{1,2}\.[\dbB]{1,3})/) or
       match_for(:chrome, /Chrome\/([\d{1,3}\.]+)/) or
       match_for(:firefox, /Firefox[ \(\/]*([a-z0-9\.\-\+]*)/i) or
       match_for(:opera, /Version\/(\d{1,2}\.\d{1,2})/) or
       match_for(:opera, /Opera[ \(\/]*(\d{1,2}\.\d{1,2})/)
      
    else
      @failed = true
      
    end
  end
  
  def match_for browser, regexp
    match = @user_agent.match regexp
    return false unless match
    
    instance_variable_set "@#{browser}", true
    @version = match.to_a.last
  end
end