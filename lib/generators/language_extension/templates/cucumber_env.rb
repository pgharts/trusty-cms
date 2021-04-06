# Sets up the Rails environment for Cucumber
ENV["Rails.env"] = "test"
# Extension root
extension_env = File.expand_path(File.dirname(__FILE__) + '/../../../../../config/environment')
require extension_env+'.rb'

Dir.glob(File.join(TRUSTY_CMS_ROOT, "features", "**", "*.rb")).each {|step| require step}

Cucumber::Rails::World.class_eval do
  include Dataset
  datasets_directory "#{TRUSTY_CMS_ROOT}/spec/datasets"
  Dataset::Resolver.default = Dataset::DirectoryResolver.new("#{TRUSTY_CMS_ROOT}/spec/datasets", File.dirname(__FILE__) + '/../../spec/datasets', File.dirname(__FILE__) + '/../datasets')
  self.datasets_database_dump_path = "#{Rails.root}/tmp/dataset"

  # dataset :<%= file_name %>
end
