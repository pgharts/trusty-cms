## Welcome to TrustyCMS

[![Gem Version](https://badge.fury.io/rb/trusty-cms.svg)](http://badge.fury.io/rb/trusty-cms)

TrustyCMS is a branch of Radiant CMS. Its goal is to pull the Radiant framework into Rails 7 with minimal changes to its
infrastructure.

TrustyCMS is a no-fluff, open source content management system designed for
small teams. It is similar to Textpattern or MovableType, but is a general
purpose content management system (not just a blogging engine). TrustyCMS is a
Rails engine and is built to be installed into an existing Rails 7 application as a gem.

CircleCI: [![CircleCI](https://circleci.com/gh/pgharts/trusty-cms/tree/master.svg?style=shield)](https://circleci.com/gh/pgharts/trusty-cms/tree/master)

CodeClimate: [![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/codeclimate)

TrustyCMS features:

* An elegant user interface
* The ability to arrange pages in a hierarchy with drag and drop
* Flexible templating with layouts, snippets, page parts, and a custom tagging
  language
* A simple user management/permissions system
* Support for Markdown and Textile as well as traditional HTML (it's easy to
  create other filters)
* An advanced plugin system
* Asset management & searching
* Serve multiple sites (domains) from a single instance
* Reusable bits of content (Snippets)
* Allows Rails controllers/actions to use Trusty CMS layouts as their "layout"
* Operates in two modes: dev and production depending on the URL
* A caching system which expires pages every 5 minutes
* Built using Ruby on Rails (version 7)

## License

TrustyCMS is released under the MIT license. The Radiant portions of the
codebase are copyright (c) John W. Long and Sean Cribbs; anything after the
fork is copyright (c) Pittsburgh Cultural Trust. A copy of the MIT license can
be found in the LICENSE file.

## Installation and Setup

TrustyCMS is a traditional Ruby on Rails engine, meaning that you can
configure and run it the way you would a normal gem, like [Devise](https://github.com/plataformatec/devise).

See the INSTALL.md file for more instructions.

### Installation

Prerequisites:

* A Github account and Git ([Github has some really good instructions](https://help.github.com/articles/set-up-git))
* Ruby 3.1 or higher
* A Rails application (currently supports version 7.0)
* Bundler
* MySQL
* [PhantomJS >= 1.8.1](https://github.com/teampoltergeist/poltergeist/tree/v1.5.0#installing-phantomjs)

Steps:

1. Fork this repository to your Github account.
1. Clone your fork to your machine.
1. `cd` into the directory you just cloned into.
1. Follow the INSTALL.md instructions to setup an empty app with TrustyCMS installed. To modify TrustyCMS,
   point your dependency to the local path of your fork.

   gem 'trusty-cms', path: '../trusty-cms'

1. Set up your databases in your Rails application:

        bundle exec rake db:create
        bundle exec rake db:migrate

1. Run the tests to make sure they pass (If they don't, file a bug!):

        rspec

### Hidden Page Status Configuration
In version `7.0.34`, TrustyCMS introduces support for custom behavior when a page is marked as **Hidden**.

While TrustyCMS does not include built-in fields for excluding hidden pages from calendars or search, parent applications can define this behavior using the `on_hidden_callback` configuration option.

To define what should happen when a page is set to Hidden, configure the callback in your initializer (e.g., `config/initializers/trusty_cms_config.rb`):

```ruby
TrustyCms::Application.config.on_hidden_callback = ->(page) do
  page.display_on_calendar = false
  page.hide_from_subnav = true
  page.indexable = false
end
```

### Preview Custom Page Types

TrustyCMS supports a preview feature for standard page types. However, this functionality may not work out of the box for custom page types. To enable the preview feature for your custom page types, follow these steps:

1. In your application, create the following initializer file: `config/initializers/preview_page_types.rb`
2. Inside this file, define a `PREVIEW_PAGE_TYPES` array constant with the names of the page types you’d like to enable the Preview button for, for example:

   ```ruby
   PREVIEW_PAGE_TYPES = %w[
     BlogPage
     FacilityPage
     FileNotFoundPage
   ].freeze
   ```
   
3. Test the Preview button with each custom page type. If a page type does not preview correctly, remove it from the list.

### Custom Page Type Routes Setup
Additional configuration is required to ensure correct URL generation in the admin interface — specifically for the "Edit Page" dropdown and the "Save and View Draft" functionality.

To enable this, create the following initializer: `config/initializers/page_type_routes.rb`

In this file, define a `CUSTOM_PAGE_TYPE_ROUTES` hash constant that maps custom Page model class names to the corresponding route segments defined in your `config/routes.rb` file. For example, the BlogPage model maps to the route `get 'blog/:slug'`, so its route segment is `'blog'`.

For custom Page models that rely on default routing behavior, define a `DEFAULT_PAGE_TYPE_ROUTES` array listing their class names. TrustyCMS will use these mappings to correctly build page URLs for use in the admin UI.

```ruby
CUSTOM_PAGE_TYPE_ROUTES = {
  BlogPage: 'blog',
  DonationPage: 'donate',
  ExhibitionPage: 'exhibit',
  NonTicketedEventPage: 'event',
  PackagePage: 'package',
  PersonPage: 'biography',
  ProductionPage: 'production',
  VenuePage: 'venues',
}.freeze

DEFAULT_PAGE_TYPE_ROUTES = %w[
  ConstituencyPage
  FacilityPage
  FileNotFoundPage
  RailsPage
].freeze
```

### Page Status Refresh Setup

To ensure **Scheduled Pages** automatically update their status to **Published** after their designated **Publish Date & Time**, follow these steps to set up an automated refresh using **AWS Lambda** and **EventBridge**.  

**1. Generate a Bearer Token**  
Open a Rails console and run the following command:  
```bash
rails c
```  
Then generate a token:  
```ruby
SecureRandom.base58(24)
```  

**2. Store the Token in Rails Credentials**  
To store your token securely, edit your Rails credentials by running the following command:
```bash
bin/rails encrypted:edit config/credentials.yml.enc
```
Then, add the token to your credentials file under the `trusty_cms` namespace:
```yaml
trusty_cms:
  page_status_bearer_token: '<your bearer token>'
```

**3. Add Google Tag Manager Container ID (Optional)**
If you'd like to enable trusty-cms to submit Google Tag Manager data for tracking admin page activity (this does not include public-facing pages), add your Google Tag Manager Container ID to the `trusty_cms` section of your `credentials.yml.enc` file:
 ```yaml
trusty_cms:
  page_status_bearer_token: '<your bearer token>'
  gtm_container_id: 'GTM-xxxxxx'
```

**4. Create a Ruby Lambda Function in AWS**  
- Log into **AWS Lambda** and create a **new Ruby Lambda function**.  
- Note the **Ruby version** used, as you'll need it locally.  
- Use [rbenv](https://github.com/rbenv/rbenv) to manage the Ruby version locally:  
  ```bash
  rbenv install 3.3.0
  rbenv local 3.3.0
  ```

**5. Write the Lambda Function Code**  
In your local development environment:  
- Create a new folder and open it in your IDE.  
- Save the following code in a file named `lambda_handler.rb`:  

```ruby
require 'httparty'

def lambda_handler(event:, context:)
  uri = ENV['API_ENDPOINT']
  token = ENV['BEARER_TOKEN']

  response = HTTParty.post(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': "Bearer #{token}"
    }
  )

  if response.success?
    puts "Success: #{response.body}"
  else
    puts "Error: #{response.code} - #{response.message}"
  end
end
```

**6. Install Dependencies**  
Run the following commands in your terminal:  
```bash
gem install bundler
bundle init
```  
Add the dependency to your `Gemfile`:  
```ruby
gem 'httparty'
```  
Install dependencies locally:  
```bash
bundle config set --local path 'vendor/bundle'
bundle install
```

**7. Package the Lambda Function**  
Archive your function and dependencies:  
```bash
zip -r lambda_package.zip .
```

**8. Upload to AWS Lambda**  
- In **AWS Lambda**, open your function.  
- Select **Upload From > .zip file**.  
- Upload the `lambda_package.zip` file.  

**9. Configure Environment Variables**  
In the AWS Lambda Configuration: 
- Go to **Environment Variables** > **Edit**.  
- Add the following:  
  - `API_ENDPOINT`: `<your-url>/page-status/refresh`  
  - `BEARER_TOKEN`: `<your bearer token>`  

**10. Set Up EventBridge Trigger**  
- In **Configuration Settings > Triggers**, create a **new EventBridge Trigger**.  
- Set the **Schedule** to match your desired **page status refresh frequency**.  

Your setup is now complete, and **Scheduled Pages** will automatically update their status via the AWS Lambda and EventBridge integration.

### Custom CKEditor5 Styles and Stylesheets

Add your stylesheets and custom styles to CKEditor in your application.

Include your website styles in your editor - add a stylesheet and `@import` the styles you want in `.ck-content`
```
.ck-content {
    @import 'path/to/stylesheets';
}
```

```
// config/initializers/trusty_cms_editor_stylesheets.rb
if defined?(TrustyCms) && TrustyCms.respond_to?(:editor_stylesheets)
  TrustyCms.editor_stylesheets |= [
    {site: 'current_site_name_underscore', path: 'path/to/ck-content/stylesheets'}
    ]
  TrustyCms.editor_style_definitions = [
    { name: 'Primary Button', element: 'a', classes: %w[button] },
    { name: 'Button Alt', element: 'a', classes: %w[button button-alt] },
    # etc…
  ]
end
```

### Contributing to TrustyCMS

When you're ready to make a change:

1. Add the pgharts fork as a git remote called "upstream":
   `git remote add upstream https://github.com/pgharts/trusty-cms.git` so that you can keep up with changes that other
   people make.
1. Fetch the remote you just added: `git fetch upstream`.
1. Start a new branch for the change you're going to make. Name it something having to do with the changes, like "
   fix-queries" if you are going to try to fix some queries. Base this branch on `upstream/master` by running
   `git checkout -b fix-queries upstream/master`.
1. Make your changes and commit them. Please include tests!
1. Run the tests and make sure they pass.
1. Push your changes to your github fork: `git push origin fix-queries`.
1. Send a pull request to the pgharts fork.

## Support

All of the development for TrustyCMS happens on Github:

https://github.com/pgharts/trusty-cms

TrustyCMS is supported in part by:

* [The Allegheny Regional Asset District (RAD)](https://www.radworkshere.org/)
* [Browserstack](https://www.browserstack.com/)

Enjoy!

--
The TrustyCMS Dev Team
