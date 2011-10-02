require 'bad_browser/user_agent/browser_version'

class UserAgent
  attr_reader :browser, :version, :string
  
  def initialize(str)
    @string = str.to_s
    @string.strip!
    
    @browser = nil
    
    detect_user_agent unless @string.empty? || @string.size > 500
  end
  
  def failed?; !(defined? @version) end
  
  def msie?; @browser == :msie; end
  def firefox?; @browser == :firefox; end
  def chrome?; @browser == :chrome; end
  def safari?; @browser == :safari; end
  def opera?; @browser == :opera; end
  
  ##
  # Convert object to a JSON representation for public consumption. Can easily use a JSON gem
  # but it's just faster to build it by hand
  def to_json(result = nil)
    browser = @browser.nil? ? 'null' : %Q("#{@browser}")
    
    if failed?
      %Q({"failed":true,"browser":#{browser},"version":null,"string":"#{@string}"})
    elsif !result.nil?
      %Q({"result":#{result},"browser":#{browser},"version":"#{@version.string}","string":"#{@string}"})
    else
      %Q({"browser":#{browser},"version":"#{@version.string}","string":"#{@string}"})
    end
  end
  
  protected
  
  ##
  # Main driver of user-agent detection. This method will run a bunch of RegExs to try and match
  # the supplied string. It matches from most popular to least popular with the exception of 
  # Opera. We have to check for opera first (via String#include?) and "jump" away since 
  # Opera tries to disguise itself as MSIE and Firefox sometimes.
  def detect_user_agent
    # "jump away" for Opera using String#include? since it's quicker than regex at this point
    return match_opera if @string.include?('Opera')
    
    match_with(:msie, /MSIE[ ]*(\d{1,2}\.[\dbB]{1,3})*/)      or 
    match_with(:firefox, /Firefox[ \(\/]*([a-z0-9\.\-\+]*)/i) or
    match_with(:chrome, /Chrome\/([\d\.]+)*/)                 or
    match_safari
  end

  ##
  # We need a special method just for Opera since it's user agent strings are a nightmare (see fixtures).
  # Opera's user-agent include various tokens and strings that try to make it look like MSIE or Firefox
  # Always set @opera as well since we know it is Opera at this point
  def match_opera
    match = match_agent(/Version\/(\d{1,2}\.\d{1,2})/) || match_agent(/Opera[ \(\/]*(\d{1,2}\.\d{1,2}[u1]*)/)
    @browser = :opera
    
    if match
      version = match.last.split('.')
      version[1] = version[1].ljust(2, '0')
      
      @version = BrowserVersion.new version.join('.')
    end
  end
  
  ## 
  # version map for Safari
  @@safari_map = {
    :'2.0.4' => ['418.8', '419'], :'2.0.3' => ['417.9', '418'], :'2.0.2' => ['416.11', '416.12'], :'2.0.1' => ['412.7', '412.7'], :'2.0' => ['412', '412.6.2'], 
    :'1.3.2' => ['312.8', '312.8.1'], :'1.3.1' => ['312.5', '312.5.2'], :'1.3' => ['312.1', '312.1.1'], :'1.2.4' => ['125.5.5', '125.5.7'], 
    :'1.2.3' => ['125.4', '125.5'], :'1.2.2' => ['125.2', '125.2'], :'1.2' => ['124', '124'],  :'1.0.3' => ['85.8.2', '85.8.5'], :'1.0' => ['85.7', '85.7'] 
  }

  ##
  # We need a special method just to handle Safari since it's user agent strings are not
  # as easily parsed as other browsers. If everything fails, we will at least look for 'Safari'
  # in the user-agent string to positively match the vendor.
  def match_safari
    unless match_with(:safari, /Version\/([\d\.[dp1]*]+) Safari/)
      if match = match_agent(/AppleWebKit\/(\d[\.\d]*)/)
        # find may return nil so this is a two step process
        result = @@safari_map.find { |v, pair| match.last >= pair.first && match.last <= pair.last }
        @version = BrowserVersion.new result.first.to_s if result
        @browser = :safari
        
      elsif @string.include?('Safari') || @string.include?('AppleWebKit')
        @browser = :safari
        
      end
    end
  end
  
  ##
  # Tries to match the user agent for the supplied browser via regex. The regex's are written so 
  # we at least can match the vendor. It's key this method returns a "trueish" value if any 
  # match is made (thus halting the OR chain in detect_user_agent)
  def match_with(browser, regex)
    match = match_agent regex
    
    @version = BrowserVersion.new match.to_a.last if match && match.size > 1
    @browser = browser if match
  end
    
  ##
  # Helper to make regex parsing a bit friendlier. It will convert the results to
  # an array and remove any nil or empty elements (or return nil if not match, the default behaviour)
  def match_agent(regex)
    match = @string.match regex
    return nil unless match
    
    match = match.to_a
    match.reject! { |m| m.nil? || m.empty? }
    
    match
  end
end