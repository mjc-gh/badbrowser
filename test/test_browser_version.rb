require File.join(File.dirname(__FILE__), 'helper')

describe BrowserVersion do
  before do
    @sets = fixture(:browser_versions).collect.with_index do |str, index|
      [ browser_version(str), str ]
    end
    
    @rsets = @sets.reverse
  end
  
  it "initailizes with strings" do
    bv = browser_version('1.2.3')
    
    bv.string.must_equal '1.2.3'
    bv.parsed.must_equal [1, 2, 3]
  end
  
  it "initializes with integers" do
    bv = browser_version(103)
    
    bv.string.must_equal '103'
    bv.parsed.must_equal [103]
  end
  
  it "initializes with floats" do
    bv = browser_version(1.230)
    
    bv.string.must_equal '1.23'
    bv.parsed.must_equal [1, 23]
  end
  
  it "initializes with an empty strings" do
    bv = browser_version('')
    
    bv.string.must_equal ''
    bv.parsed.must_equal []
  end
    
  it "compares versions correctly" do
    @sets.each.with_index do |set, index|
      break if index == @sets.size - 1
      bv, nbv, nstr = set.first, *@sets[index + 1]
      
      (bv <=> nbv).must_equal -1
      (bv <=> nstr).must_equal -1
    end
    
    # could do this inabove loop but this is just cleaner
    @sets.each do |set|
      bv, str = *set
      
      (bv <=> browser_version(str)).must_equal 0
      (bv <=> bv).must_equal 0
      (bv <=> str).must_equal 0
    end
    
    @rsets.each.with_index do |set, index|
      break if index == @rsets.size - 1
      bv, nbv, nstr = set.first, *@rsets[index + 1]

      (bv <=> nbv).must_equal 1
      (bv <=> nstr).must_equal 1
    end
  end
  
  it "has all rational operators" do
    bv = browser_version('1.0')
  end
  
  bench_performance_linear 'for operators' do |n|
    s1, s2 = @sets.first, @sets.last
    bv1, bv2 = s1.first, s2.first
    
    n.times { bv1 <=> bv2 }      
  end
end