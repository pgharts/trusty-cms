Rails.autoloaders.each do |autoloader|
  autoloader.inflector.inflect(
    'clipped_admin_ui' => 'ClippedAdminUI',
    'admin_ui' => 'AdminUI',
  # Add more inflections as needed
  )
end