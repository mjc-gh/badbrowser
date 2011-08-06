require File.join(File.dirname(__FILE__), 'helper')



describe "AgentDetector" do
  it "marks as failed with empty user agents" do
    user_agent(nil).failed?.must_equal true
    user_agent('').failed?.must_equal true 
  end
  
  # dynamic set of tests that use the user_agent fixture to generate themselves
  fixture(:user_agents).each do |browser, versions|
    describe "#{versions.delete(:full_name) || browser}" do
      versions.each do |version, list|
        it "matches #{version}" do
          list.each do |agent|
            ua = user_agent(agent)
            
            if version.eql?(:invalid)
              us.failed?.must_equal true
            
            else
              ua.version.must_equal version
              ua.send("#{browser}?").wont_be_nil
              
            end
          end          
        end        
      end
    end
  end  
end