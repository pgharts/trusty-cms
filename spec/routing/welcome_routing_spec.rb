require "rails_helper"

RSpec.describe "routes for Welcome", :type => :routing do
  it "routes /admin/welcome to the admin/welcome controller" do
    expect(get("/admin/welcome")).
      to route_to("admin/welcome#index")
  end

  it "routes /admin/login to the admin/welcome controller" do
    expect(get("/admin/login")).
      to route_to("admin/welcome#login")
  end

  it "routes /admin/logout to the admin/welcome controller" do
    expect(get("/admin/logout")).
      to route_to("admin/welcome#logout")
  end
end
