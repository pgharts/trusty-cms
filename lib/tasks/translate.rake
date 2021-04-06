namespace :trusty_cms do
  namespace :i18n do
    desc 'Syncs all available translations to the English master'
    task sync: :environment do
      # All places TrustyCms can store locales
      locale_paths = TrustyCms::AvailableLocales.locale_paths
      # The main translation root, basically where English is kept
      language_root = "#{TRUSTY_CMS_ROOT}/config/locales"
      words = TranslationSupport.get_translation_keys(language_root)
      locale_paths.each do |path|
        if path == language_root || path.match('language_pack')
          Dir["#{path}/*.yml"].each do |filename|
            next if filename.match('_available_tags')

            basename = File.basename(filename, '.yml')
            puts "Syncing #{basename}"
            (comments, other) = TranslationSupport.read_file(filename, basename)
            words.each { |k, _v| other[k] ||= words[k] }  # Initializing hash variable as empty if it does not exist
            other.delete_if { |k, _v| !words[k] }         # Remove if not defined in en.yml
            TranslationSupport.write_file(filename, basename, comments, other)
          end
        end
      end
    end

    desc 'Creates or updates the English available tag descriptions'
    task available_tags: :environment do
      descriptions = Hash.new
      Page.tag_descriptions.sort.each do |tag, desc|
        tag = '    ' + tag.gsub(':', '-') + ':'
        desc = desc.gsub('    ', '      ')
        descriptions[tag] = ' "' + desc.gsub('%', '&#37;').gsub('"', '\"').strip + '"'
      end
      comments = ''
      TranslationSupport.write_file("#{TRUSTY_CMS_ROOT}/config/locales/en_available_tags.yml", "---\nen:\n  desc", comments, descriptions)
    end

    desc 'Syncs all translations available_tags to the English master'
    task sync_available_tags: :environment do
      # All places TrustyCms can store locales
      locale_paths = TrustyCms::AvailableLocales.locale_paths
      # The main translation root, basically where English is kept
      language_root = "#{TRUSTY_CMS_ROOT}/config/locales"
      words = TranslationSupport.open_available_tags("#{language_root}/en_available_tags.yml")
      locale_paths.each do |path|
        if path == language_root || path.match('language_pack')
          Dir["#{path}/*.yml"].each do |filename|
            next unless filename.match('_available_tags')

            basename = File.basename(filename, '_available_tags.yml')
            puts "Syncing #{basename}"
            (comments, other) = TranslationSupport.open_available_tags(filename)
            puts other
          end
        end
      end
    end
  end
end
