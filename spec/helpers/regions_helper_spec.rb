require 'rails_helper'

RSpec.describe Admin::RegionsHelper, type: :helper do

  describe "#render_region" do

    before :each do
      allow(controller).to receive(:controller_name).and_return("page")
      allow(controller).to receive(:template_name).and_return("index")
    end

    it "outputs html_safe string" do
      expect(helper.render_region :foo).to be_html_safe
    end
  end
end
