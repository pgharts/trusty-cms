def obtain_class
  class_name = ENV['CLASS'] || ENV['class']
  raise "Must specify CLASS" unless class_name
  Object.const_get(class_name)
end

def obtain_attachments(klass)
  name = ENV['ATTACHMENT'] || ENV['attachment']
  attachment_names = if klass.respond_to?(:reflect_on_all_attachments)
                       klass.reflect_on_all_attachments.map(&:name)
                     else
                       []
                     end
  raise "Class #{klass.name} has no ActiveStorage attachments" if attachment_names.empty?
  if name.present? && attachment_names.include?(name.to_sym)
    [name.to_sym]
  else
    attachment_names
  end
end

def for_all_attachments
  klass = obtain_class
  names = obtain_attachments(klass)

  klass.find_each do |instance|
    names.each do |name|
      attachment = instance.public_send(name)
      result = if attachment.attached?
                 yield(instance, name, attachment)
               else
                 true
               end
      print result ? "." : "x"; $stdout.flush
    end
  end
  puts " Done."
end

namespace :active_storage do
  desc "Refreshes both metadata and variants."
  task :refresh => ["active_storage:refresh:metadata", "active_storage:refresh:variants"]

  namespace :refresh do
    desc "Regenerates variants for a given CLASS (and optional ATTACHMENT)."
    task :variants => :environment do
      for_all_attachments do |instance, name, attachment|
        if instance.respond_to?(:refresh_variants!) && name == :asset
          instance.refresh_variants!
        else
          attachment.preview if attachment.previewable?
        end
        true
      end
    end

    desc "Re-analyzes metadata for a given CLASS (and optional ATTACHMENT)."
    task :metadata => :environment do
      for_all_attachments do |instance, name, attachment|
        attachment.analyze unless attachment.analyzed?
        instance.save(validate: false)
        true
      end
    end
  end
end
