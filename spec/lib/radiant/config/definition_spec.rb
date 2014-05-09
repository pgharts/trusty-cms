require File.dirname(__FILE__) + "/../../../spec_helper"

describe "TrustyCms::Config::Definition" do
  before :each do
    TrustyCms::Config.initialize_cache
    @basic = TrustyCms::Config::Definition.new({
      :default => 'quite testy'
    })
    @boolean = TrustyCms::Config::Definition.new({
      :type => :boolean,
      :default => true
    })
    @integer = TrustyCms::Config::Definition.new({
      :type => :integer,
      :default => 50
    })
    @validating = TrustyCms::Config::Definition.new({
      :default => "Monkey",
      :validate_with => lambda {|s| s.errors.add(:value, "That's no monkey") unless s.value == "Monkey" }
    })
    @selecting = TrustyCms::Config::Definition.new({
      :default => "Monkey",
      :select_from => [["m", "Monkey"], ["g", "Goat"]]
    })
    @selecting_from_hash = TrustyCms::Config::Definition.new({
      :default => "Non-monkey",
      :allow_blank => true,
      :select_from => {"monkey" => "Definitely a monkey", "goat" => "No fingers", "Bear" => "Angry, huge", "Donkey" => "Non-monkey"}
    })
    @selecting_required = TrustyCms::Config::Definition.new({
      :default => "other",
      :allow_blank => false,
      :select_from => lambda { ['recent', 'other', 'misc'] }
    })
    @enclosed = "something"
    @selecting_at_runtime = TrustyCms::Config::Definition.new({
      :default => "something",
      :select_from => lambda { [@enclosed] }
    })
    @protected = TrustyCms::Config::Definition.new({
      :default => "Monkey",
      :allow_change => false
    })
    @hiding = TrustyCms::Config::Definition.new({
      :default => "Secret Monkey",
      :allow_display => false
    })
    @present = TrustyCms::Config::Definition.new({
      :default => "Hola",
      :allow_blank => false
    })
  end
  after :each do 
    TrustyCms::Cache.clear
    TrustyCms.config.clear_definitions!
  end

  describe "basic definition" do
    before do
      TrustyCms.config.define('test', @basic)
      @setting = TrustyCms::Config.find_by_key('test')
    end

    it "should specify a default" do
      @basic.default.should == "quite testy"
      @setting.value.should == "quite testy"
      TrustyCms::Config['test'].should == 'quite testy'
    end
  end
  
  describe "validating" do
    before do
      TrustyCms::Config.define('valid', @validating)
      TrustyCms::Config.define('number', @integer)
      TrustyCms::Config.define('selecting', @selecting)
      TrustyCms::Config.define('required', @present)
    end

    it "should validate against the supplied block" do
      setting = TrustyCms::Config.find_by_key('valid')
      lambda{setting.value = "Ape"}.should raise_error
      setting.valid?.should be_false
      setting.errors.on(:value).should == "That's no monkey"
    end

    it "should allow a valid value to be set" do
      lambda{TrustyCms::Config['valid'] = "Monkey"}.should_not raise_error
      TrustyCms::Config['valid'].should == "Monkey"
      lambda{TrustyCms::Config['selecting'] = "Goat"}.should_not raise_error
      lambda{TrustyCms::Config['selecting'] = ""}.should_not raise_error
      lambda{TrustyCms::Config['integer'] = "27"}.should_not raise_error
      lambda{TrustyCms::Config['integer'] = 27}.should_not raise_error
      lambda{TrustyCms::Config['required'] = "Still here"}.should_not raise_error
    end

    it "should not allow an invalid value to be set" do
      lambda{TrustyCms::Config['valid'] = "Cow"}.should raise_error
      TrustyCms::Config['valid'].should_not == "Cow"
      lambda{TrustyCms::Config['selecting'] = "Pig"}.should raise_error
      lambda{TrustyCms::Config['number'] = "Pig"}.should raise_error
      lambda{TrustyCms::Config['required'] = ""}.should raise_error
    end
  end

  describe "offering selections" do
    before do
      TrustyCms::Config.define('not', @basic)
      TrustyCms::Config.define('now', @selecting)
      TrustyCms::Config.define('hashed', @selecting_from_hash)
      TrustyCms::Config.define('later', @selecting_at_runtime)
      TrustyCms::Config.define('required', @selecting_required)
    end
    
    it "should identify itself as a selector" do
      TrustyCms::Config.find_by_key('not').selector?.should be_false
      TrustyCms::Config.find_by_key('now').selector?.should be_true
    end
    
    it "should offer a list of options" do
      TrustyCms::Config.find_by_key('required').selection.should have(3).items
      TrustyCms::Config.find_by_key('now').selection.include?(["", ""]).should be_true
      TrustyCms::Config.find_by_key('now').selection.include?(["m", "Monkey"]).should be_true
      TrustyCms::Config.find_by_key('now').selection.include?(["g", "Goat"]).should be_true
    end
        
    it "should run a supplied selection block" do
      @enclosed = "testing"
      TrustyCms::Config.find_by_key('later').selection.include?(["testing", "testing"]).should be_true
    end
    
    it "should normalise the options to a list of pairs" do
      TrustyCms::Config.find_by_key('hashed').selection.is_a?(Hash).should be_false
      TrustyCms::Config.find_by_key('hashed').selection.include?(["monkey", "Definitely a monkey"]).should be_true
    end

    it "should not include a blank option if allow_blank is false" do
      TrustyCms::Config.find_by_key('required').selection.should have(3).items
      TrustyCms::Config.find_by_key('required').selection.include?(["", ""]).should be_false
    end
    
  end
  
  describe "protecting" do
    before do
      TrustyCms::Config.define('required', @present)
      TrustyCms::Config.define('fixed', @protected)
    end
    
    it "should raise a ConfigError when a protected value is set" do
      lambda{ TrustyCms::Config['fixed'] = "different" }.should raise_error(TrustyCms::Config::ConfigError)
    end
    
    it "should raise a validation error when a required value is made blank" do
      lambda{ TrustyCms::Config['required'] = "" }.should raise_error
    end
  end


end

