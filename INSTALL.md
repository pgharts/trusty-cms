# Installation and Setup

From within the directory containing your TrustyCMS instance:

1. Create a new Rails 7.0+ application (i.e. `rails new [project_name]`)

2. Add the following gems to your Gemfile:

    - gem 'trusty-cms'
    - gem 'rails-observers'

3. Run `bundle install`

4. Run the Trusty CMS generator to get the project into shape: `rails g trusty_cms [project_name]`.
    - This will ask you if you want to replace a number of existing files (like application.rb); reply Y to all.

5. Add `config.extensions = [ :snippets, :clipped, :layouts, :multi_site ]` to enable them in application.rb

6. Add `config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]` to application.rb. This is required for pages to save previous versions.

7. Add utf8 encoding to your db.yml

8. Set up encryption keys required for Rails’ native encryption (used by features like two-factor authentication):

    - Run the encryption initializer command:

    ```bash
    ./bin/rails db:encryption:init
    ```

    - This will output three secrets. Copy the values and set them as environment variables in your preferred environment file (e.g., `.env`, `.env.development`, or via system environment settings):

    ```env
    ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
    ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
    ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
    ```
    - **Important**: Use different keys for each environment (development, test, production) unless two environments (e.g., development and staging) share a database — in that case, they **must** use the same keys.

9. Run `bundle exec rake db:setup`, `bundle exec rake trusty_cms:install:migrations`, then
   `bundle exec rake db:bootstrap`.
