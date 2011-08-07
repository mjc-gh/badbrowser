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
    
    unless @user_agent.empty?
      detect_user_agent
    else
      @failed = true 
    end
  end
  
  def failed?
    !!@failed
  end
  
  def msie?; @msie; end  
  def gecko?; @gecko; end
  def chrome?; @chrome; end
  def safari?; @safari; end
  def opera?; @opera; end
  
  private 
  
  def detect_user_agent
    if match = match_or_fail(/MSIE (\d{1,2}\.\w{1,3})/)
      @msie = true
      @version = match.last
    
    elsif match = match_or_fail(/Chrome\/([\d{1,3}\.]+)/)
      @chrome = true
      @version = match.last
    
    else
      @failed = true
      
    end
  end
  
  def match_or_fail regexp
    match = @user_agent.match regexp
    
    @failed = true and return nil unless match
    
    match.to_a
  end
end