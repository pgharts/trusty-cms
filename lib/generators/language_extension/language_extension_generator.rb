class LanguageExtensionGenerator < Rails::Generator::NamedBase
  default_options :with_test_unit => false

  attr_reader :extension_path, :extension_file_name, :localization_name

  def initialize(runtime_args, runtime_options = {})
    super
    @extension_file_name = "#{file_name}_language_pack_extension"
    @extension_path = "vendor/extensions/#{file_name}_language_pack"
    @localization_name = localization_name
  end

  def manifest
    record do |m|
      m.directory "#{extension_path}/config/locales"
      m.directory "#{extension_path}/lib/tasks"

      m.template 'README',                "#{extension_path}/README"
      m.template 'extension.rb',          "#{extension_path}/#{extension_file_name}.rb"
      # m.template 'tasks.rake',            "#{extension_path}/lib/tasks/#{extension_file_name}_tasks.rake"
      m.template 'lang.yml',              "#{extension_path}/config/locales/#{localization_name}.yml"
      m.template 'available_tags.yml',    "#{extension_path}/config/locales/#{localization_name}_available_tags.yml"
      m.template 'lib.rb',                "#{extension_path}/lib/radiant-#{file_name}_language_pack-extension.rb"
      m.template 'gemspec.rb',            "#{extension_path}/radiant-#{file_name}_language_pack-extension.gemspec"
    end

  end

  def class_name
    super.to_name.gsub(' ', '') + 'LanguagePackExtension'
  end

  def extension_name
    class_name.to_name('Extension')
  end

  def author_info
    @author_info ||= begin
      Git.global_config
    rescue NameError
      {}
    end
  end

  def homepage
    author_info['github.user'] ? "http://github.com/#{author_info['github.user']}/radiant-#{file_name}-extension" : "http://example.com/#{file_name}"
  end

  def author_email
    author_info['user.email'] || 'your email'
  end

  def author_name
    author_info['user.name'] || 'Your Name'
  end

  def add_options!(opt)
    # opt.separator ''
    # opt.separator 'Options:'
    # opt.on("--with-test-unit",
    #        "Use Test::Unit for this extension instead of RSpec") { |v| options[:with_test_unit] = v }
  end

  def localization_name
    file_name.split('_')[1] ? "#{file_name.split('_')[0]}-#{file_name.split('_')[1].upcase}" : file_name
  end

  def copy_files
    FileUtils.cp("#{TRUSTY_CMS_ROOT}/config/locales/en_available_tags.yml","#{TRUSTY_CMS_ROOT}/#{extension_path}/config/locales/#{localization_name}_available_tags.yml")
  end
end
