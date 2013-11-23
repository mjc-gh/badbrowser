require 'helper'

describe UserAgent do
  it "fails with empty user agents" do
    user_agent(nil).failed?.must_equal true
    user_agent('').failed?.must_equal true
  end

  it "fails on more than 500 character" do
    user_agent('A' * 501).failed?.must_equal true
  end

  # Can only include what is detected after the test target or else the wrong browser is matched
  # Don't test for Opera and Safari since Opera "jumps away" and Safari is last
  it "only match a single browser" do
    ff = user_agent('Firefox Chrome Safari')
    msie = user_agent('MSIE Firefox Chrome')
    chrome = user_agent('Chrome/ Safari')

    ff.chrome?.must_equal false
    ff.msie?.must_equal false
    ff.firefox?.must_equal true

    msie.chrome?.must_equal false
    msie.firefox?.must_equal false
    msie.msie?.must_equal true

    chrome.msie?.must_equal false
    chrome.firefox?.must_equal false
    chrome.chrome?.must_equal true
  end

  describe "to json" do
    it "with full match" do
      str = 'Mozilla/5.0 (compatible; MSIE 6.0;)'
      json = JSON.parse(user_agent(str).to_json(false))

      json['browser'].must_equal 'msie'
      json['version'].must_equal '6.0'
      json['string'].must_equal str
    end

    it "with no version" do
      str = 'Mozilla/5.0 (compatible; MSIE)'
      json = JSON.parse(user_agent(str).to_json)

      json['failed'].must_equal true
      json['browser'].must_equal 'msie'
      json['version'].must_equal nil
      json['string'].must_equal str
    end

    it "with no match" do
      str = 'Mozilla/5.0 (compatible;)'
      json = JSON.parse(user_agent(str).to_json)

      json['failed'].must_equal true
      json['browser'].must_equal nil
      json['version'].must_equal nil
      json['string'].must_equal str
    end

    it "with match and result" do
      str = 'Mozilla/5.0 (compatible; MSIE 6.0;)'
      json = JSON.parse(user_agent(str).to_json(true))

      json['result'].must_equal true
      json['failed'].must_be_nil

      json['browser'].must_equal 'msie'
      json['version'].must_equal '6.0'
      json['string'].must_equal str
    end
  end

  user_agent_fixtures.each do |fixture, versions|
    next unless versions

    browser = fixture.sub(/\.yml/, '')
    next if ENV['SKIP'].to_s.include? browser

    describe "#{browser.capitalize}" do
      versions.each do |version, list|
        if version.empty?
          it "matches browser with no versions" do
            list.each do |agent|
              ua = user_agent(agent)

              ua.failed?.must_equal true
              ua.version.must_be_nil

              ua.browser.must_equal browser.to_sym
              ua.send("#{browser}?").wont_be_nil
            end
          end
        else
          it "matches #{version}" do
            list.each do |agent|
              ua = user_agent(agent)

              ua.failed?.must_equal false
              ua.version.must_be :==, version

              ua.browser.must_equal browser.to_sym
              ua.send("#{browser}?").wont_be_nil
            end
          end
        end
      end

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
    end

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
