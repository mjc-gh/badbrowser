require File.join(File.dirname(__FILE__), 'helper')

describe "AgentDetector" do
  it "marks as failed with empty user agents" do
    user_agent(nil).failed?.must_equal true
    user_agent('').failed?.must_equal true 
  end
  
  user_agent_fixtures.each do |fixture, content|
    next unless content[:versions]
    browser = fixture.sub(/\.yml/, '')
    
    describe "#{content[:fullname] || fixture}" do
      content[:versions].each do |version, list|
        it "matches #{version}" do
          list.each do |agent|
            ua = user_agent(agent)
            
            if version.eql?(:invalid)
              ua.failed?.must_equal true
              ua.version.must_be_nil
            
            else
              ua.version.must_equal version
              ua.send("#{browser}?").wont_be_nil
              
            end
          end
        end # it block
      end # each version
    end # describe block
  end # each fixture 
end