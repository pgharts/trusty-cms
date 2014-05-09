require File.dirname(__FILE__) + "/../../spec_helper"

describe TrustyCms::AvailableLocales do

  before :each do
    @locales = TrustyCms::AvailableLocales.locales
  end
  
  it "should load the default locales" do
    @locales.should include(["English", "en"])
  end
  
end