# frozen_string_literal: true

# Define a namespace for the task
namespace :import do
  desc 'Imports the legacy user data into the Devise Admin table'
  task admins: :environment do
    LegacyUser.all.each do |legacy|
      u = User.new(
        email: legacy.email,
        first_name: legacy.name.split(' ')[0],
        last_name: legacy.name.split(' ')[1],
        password: 'PleaseChangeMe1!',
        password_confirmation: 'PleaseChangeMe1!',
        admin: legacy.admin,
        designer: legacy.designer,
        content_editor: legacy.content_editor,
        notes: legacy.notes
      )
      u.save!
    end
  end
end