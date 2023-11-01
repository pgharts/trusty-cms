Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'clipped_admin_ui' => 'ClippedAdminUI',
    'admin_ui' => 'AdminUI',
    'ostruct' => 'OpenStruct',
  # Add more inflections as needed
  )
end