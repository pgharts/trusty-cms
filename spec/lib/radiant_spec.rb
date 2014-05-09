require File.dirname(__FILE__) + "/../spec_helper"

describe TrustyCms do
  it "should detect whether loaded via gem" do
    TrustyCms.should respond_to(:loaded_via_gem?)
  end
end

describe TrustyCms::Version do
  it "should have a constant for the major revision" do
    lambda { TrustyCms::Version::Major }.should_not raise_error(NameError)
  end
  
  it "should have a constant for the minor revision" do
    lambda { TrustyCms::Version::Minor }.should_not raise_error(NameError)
  end

  it "should have a constant for the tiny revision" do
    lambda { TrustyCms::Version::Tiny }.should_not raise_error(NameError)
  end

  it "should have a constant for the patch revision" do
    lambda { TrustyCms::Version::Patch }.should_not raise_error(NameError)
  end
  
  it "should join the revisions into the version number" do
    TrustyCms::Version.to_s.should be_kind_of(String)
    TrustyCms::Version.to_s.should == [TrustyCms::Version::Major, TrustyCms::Version::Minor, TrustyCms::Version::Tiny, TrustyCms::Version::Patch].delete_if{|v| v.nil?}.join(".")
  end
end
