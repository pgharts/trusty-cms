# frozen_string_literal: true

# Define a namespace for the task
namespace :import do
  desc 'Imports the legacy user data into the Devise Admin table'
  task admins: :environment do
    CHARS = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a + (1..9).to_a + ['`', '~', '!', '@', '#', '$', '%', '^', '&', '*']
    password = CHARS.sort_by { rand }.join[0...15]

    LegacyUser.all.each do |legacy|
      u = User.new(
        email: legacy.email,
        first_name: legacy.name.split(' ')[0],
        last_name: legacy.name.split(' ')[1],
        password: password,
        password_confirmation: password,
        admin: legacy.admin,
        designer: legacy.designer,
        content_editor: legacy.content_editor,
        notes: legacy.notes,
      )
      u.save!
    end
  end
end