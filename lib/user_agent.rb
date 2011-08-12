module Sinatra
  module UserAgent
    def user_agent
      @user_agent ||= AgentDetector.new(request.user_agent)
    end
  end
end

class AgentDetector
  attr_reader :user_agent, :version, :match
  
  def initialize str
    @user_agent = str.to_s
    @user_agent.strip!

    detect_user_agent unless @user_agent.empty?
    @failed = @version.nil?
  end
  
  def failed?; @failed; end
  
  def msie?; @msie; end
  def firefox?; @firefox; end
  def chrome?; @chrome; end
  def safari?; @safari; end
  def opera?; @opera; end
  
  protected 
  
  def detect_user_agent
    # "jump away" for Opera (and Safari?) 
    # String#include? is used here since it's quicker than RegEx at this point in detection
    return parse_opera if @user_agent.include?('Opera')
    
    match_for(:msie, /MSIE[ ]*(\d{1,2}\.[\dbB]{1,3})*/) or 
    match_for(:firefox, /Firefox[ \(\/]*([a-z0-9\.\-\+]*)/i) or
    match_for(:chrome, /Chrome\/([\d{1,3}\.]+)*/)
  end
  
  # We need a special method just for Opera since
  # it's user agent strings are a nightmare (see fixtures)
  # We will also always set the browser to @opera since we 
  # know it is opera at this point
  def parse_opera
    match = match_agent(/Version\/(\d{1,2}\.\d{1,2})/) || match_agent(/Opera[ \(\/]*(\d{1,2}\.\d{1,2}[u1]*)/)
    
    @version = match.last if match
    @opera = true
  end
  
  # Tries to match the user agent for the supplied browser via some regex
  # Regex are written so we at least can match the vendor
  def match_for browser, regex
    match = match_agent regex

    @version = match.to_a.last if match && match.size > 1
    instance_variable_set "@#{browser}", true if match
    @match = match
  end
  
  def match_agent regex
    match = @user_agent.match regex
    return nil unless match
    
    match = match.to_a
    match.reject! { |m| m.nil? || m.empty? }
    
    match
  end
end