Dir.glob("#{TRUSTY_CMS_ROOT}/spec/matchers/*.rb").each do |matcher|
  require matcher
end