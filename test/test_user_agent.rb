require File.join(File.dirname(__FILE__), 'helper')

describe "AgentDetector" do
  it "fails with empty user agents" do
    user_agent(nil).failed?.must_equal true
    user_agent('').failed?.must_equal true 
  end
  
  it "fails on more than 500 character" do
    user_agent('A' * 501).failed?.must_equal true
  end
  
  user_agent_fixtures.each do |fixture, versions|
    next unless versions
    
    browser = fixture.sub(/\.yml/, '')
    next if ENV['SKIP'].to_s.include? browser
    
    describe "#{browser.capitalize}" do
      versions.each do |version, list|

        # this isn't terribly DRY but it results better generated tests    
        if version.empty?
          it "matches browser with no versions" do
            list.each do |agent|
              ua = user_agent agent

              ua.failed?.must_equal true
              ua.version.must_be_nil
              ua.send("#{browser}?").wont_be_nil
            end
          end
        else        
          it "matches #{version}" do
            list.each do |agent|
              ua = user_agent agent
              
              ua.failed?.must_equal false
              ua.version.must_be :==, version
              ua.send("#{browser}?").wont_be_nil
            end
          end
        end
      end # each version
      
      it "correctly compares different versions" do
        arr = versions.to_a
        
        arr.each.with_index do |set, index|
          next_set = arr[index + 1]
          next if next_set.nil? || next_set.first.empty?
          
          cur_list = set.last
          next_list = next_set.last

          ua1 = user_agent cur_list.first
          ua2 = user_agent next_list.first

          ua1.version.must_be :>, ua2.version
          ua1.version.must_be :>=, ua2.version
        end
      end
      
    end # describe block
    
    describe "#{browser.capitalize} performance" do
      agents = []
      versions.each { |v, list| agents += list }
      
      bench_performance_linear 'on matching' do |n|
        n.times do
          user_agent agents[ rand(agents.size - 1) ]
        end
      end
    end
    
  end # each fixture 
end