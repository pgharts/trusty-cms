class ChangeUserLanguageToLocale < ActiveRecord::Migration[5.2]
  def self.up
    rename_column 'users', 'language', 'locale'
  end

  def self.down
    rename_column 'users', 'locale', 'language'
  end
end
