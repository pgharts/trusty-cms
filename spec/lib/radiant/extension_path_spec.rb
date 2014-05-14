require File.dirname(__FILE__) + "/../../spec_helper"

describe TrustyCms::ExtensionPath do
  
  let(:ep) { TrustyCms::ExtensionPath.from_path(File.expand_path("#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/basic")) }
  let(:gem_ep) { TrustyCms::ExtensionPath.from_path("/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0") }
  let(:git_ep) { TrustyCms::ExtensionPath.from_path("/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae") }

  describe "recording a vendored extension" do
    it "should parse the name of the extension from the path" do
      ep.name.should == 'basic'
    end
    
    it "should return the basename of the extension file that should be required" do
      ep.required.should == File.expand_path("#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/basic/basic_extension")
    end
    
    it "should return the extension path" do
      ep.path.should == File.expand_path("#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/basic")
      ep.to_s.should == File.expand_path("#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/basic")
    end
    
    it "should store the extension path object" do
      TrustyCms::ExtensionPath.find(:basic).path.should == ep.path
      TrustyCms::ExtensionPath.for(:basic).should == File.expand_path("#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/basic")
    end
  end

  describe "recording a gem extension" do
    it "should parse the name of the extension from the gem path" do
      gem_ep.name.should == 'gem_ext'
    end

    it "should return the name of the extension file" do
      gem_ep.required.should == "/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0/gem_ext_extension"
    end

    it "should return the extension path" do
      gem_ep.path.should == "/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0"
      gem_ep.to_s.should == "/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0"
    end

    it "should store the extension path object" do
      TrustyCms::ExtensionPath.find(:gem_ext).path.should == gem_ep.path
      TrustyCms::ExtensionPath.for(:gem_ext).should == "/imaginary/test/path/gems/radiant-gem_ext-extension-0.0.0"
    end
  end

  describe "recording a git-repository extension" do
    it "should parse the name of the extension from the gem path" do
      git_ep.name.should == 'git_ext'
    end

    it "should return the name of the extension file" do
      git_ep.required.should == "/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae/git_ext_extension"
    end

    it "should return the extension path" do
      git_ep.path.should == "/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae"
      git_ep.to_s.should == "/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae"
    end

    it "should store the extension path object" do
      TrustyCms::ExtensionPath.find(:git_ext).path.should == git_ep.path
      TrustyCms::ExtensionPath.for(:git_ext).should == "/imaginary/test/path/vendor/extensions/radiant-git_ext-extension-61e0ad14a3ae"
    end
  end

  describe "looking for load paths" do
    before do
      TrustyCms::ExtensionPath.clear_paths!
      @configuration = mock("configuration")
      TrustyCms.stub!(:configuration).and_return(@configuration)
      @extensions = %w{basic overriding}
      @extensions.each do |ext|
        TrustyCms::ExtensionPath.from_path(File.expand_path("#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/#{ext}"))
      end
      @configuration.stub!(:enabled_extensions).and_return(@extensions.map(&:to_sym))
    end
    
    describe "in an individual extension root" do
      [:load_paths, :plugin_paths, :controller_paths, :view_paths, :metal_paths, :locale_paths].each do |meth|
        it "should respond to #{meth}" do
          ep = TrustyCms::ExtensionPath.find(:basic)
          ep.should respond_to(meth)
        end
      end
      
      it "should report paths that exist" do
        File.directory?(TrustyCms::ExtensionPath.find(:basic).plugin_paths).should be_true
        File.directory?(TrustyCms::ExtensionPath.find(:basic).metal_paths).should be_true
        File.directory?(TrustyCms::ExtensionPath.find(:basic).model_paths).should be_true
        File.directory?(TrustyCms::ExtensionPath.find(:basic).view_paths).should be_true
        File.directory?(TrustyCms::ExtensionPath.find(:overriding).plugin_paths).should be_true
        File.directory?(TrustyCms::ExtensionPath.find(:overriding).metal_paths).should be_true
        File.directory?(TrustyCms::ExtensionPath.find(:overriding).view_paths).should be_true
      end
      it "should not report paths that don't exist" do
        TrustyCms::ExtensionPath.find(:basic).locale_paths.should be_nil
        TrustyCms::ExtensionPath.find(:overriding).controller_paths.should be_nil
        TrustyCms::ExtensionPath.find(:overriding).model_paths.should be_nil
        TrustyCms::ExtensionPath.find(:overriding).locale_paths.should be_nil
      end
    end

    describe "across the set of enabled extensions" do
      [:load_paths, :plugin_paths, :controller_paths, :view_paths, :metal_paths, :locale_paths].each do |meth|
        it "should return collected #{meth}" do
          TrustyCms::ExtensionPath.should respond_to(meth)
          TrustyCms::ExtensionPath.send(meth).should be_instance_of(Array)
          TrustyCms::ExtensionPath.send(meth).all? { |f| File.directory?(f) }.should be_true
        end
      end

      it "should return view_paths in inverse load order" do
        TrustyCms::ExtensionPath.view_paths.should == [
         "#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/overriding/app/views",
         "#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/basic/app/views"
        ]
      end

      it "should return metal_paths in inverse load order" do
        TrustyCms::ExtensionPath.metal_paths.should == [
         "#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/overriding/app/metal",
         "#{TRUSTY_CMS_ROOT}/test/fixtures/extensions/basic/app/metal"
        ]
      end
    end

  end

end