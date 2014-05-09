# # Redefined standard Rails tasks only in instance mode
# unless TrustyCms.app?
#   require 'rake/testtask'
#
#   ENV['RADIANT_ENV_FILE'] = File.join(Rails.root, 'config', 'environment')
#
#   [Dir["#{Rails.Root}/vendor/rails/railties/lib/tasks/*.rake"], Dir["#{Rails.root}/vendor/plugins/rspec_on_rails/tasks/*.rake"]].flatten.each do |rake|
#     lines = IO.readlines(rake)
#     lines.map! do |line|
#       line.gsub!('Rails.root', 'RADIANT_ROOT') unless rake =~ /(misc|rspec|databases)\.rake$/
#       case rake
#       when /testing\.rake$/
#         line.gsub!(/t.libs << (["'])/, 't.libs << \1#{RADIANT_ROOT}/')
#         line.gsub!(/t\.pattern = (["'])/, 't.pattern = \1#{RADIANT_ROOT}/')
#       when /databases\.rake$/
#         line.gsub!(/(migrate|rollback)\((["'])/, '\1(\2#{RADIANT_ROOT}/')
#         line.gsub!(/(run|new)\((:up|:down), (["'])db/, '\1(\2, \3#{RADIANT_ROOT}/db')
#       end
#       line
#     end
#     eval(lines.join("\n"), binding, rake)
#   end
# end