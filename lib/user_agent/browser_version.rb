# The parse and <=> methods in this class use logic from the RubyGems project,
# in particular, the Gem::Version class. For details on RubyGems see:
# https://github.com/rubygems/rubygems

class BrowserVersion
  include Comparable
  attr_reader :string, :parsed

  ##
  # Will convert the version argument to a string
  # and proceed to parse it and save the results
  def initialize version
    @string = version.to_s
    @parsed = parse @string
  end
  
  ##
  # Most of the logic in this method is borrowed from Gem::Version#<=>
  def <=> other
    other_str = self.class === other ? other.string : other.to_s
    
    return 0 if @string == other_str
    
    lhs_parsed, rhs_parsed = @parsed, parse(other_str)
    limit = (lhs_parsed.size > rhs_parsed.size ? lhs_parsed.size : rhs_parsed.size) - 1
    
    i = 0
    while i <= limit do
      lhs, rhs = lhs_parsed[i] || 0, rhs_parsed[i] || 0
      i += 1
      
      next if lhs == rhs

      return -1 if String  === lhs && Numeric === rhs
      return  1 if Numeric === lhs && String === rhs
      return lhs <=> rhs
    end
    
    return 0
  end
  
  protected
  
  ##
  # Logic in this method borrowed from Gem::Version#segments
  def parse version
    version.scan(/[0-9]+|[A-z]+/).collect! do |str|
      str =~ /^\d+$/ ? str.to_i : str
    end
  end
end