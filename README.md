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
* Social sharing buttons
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

#### App Setup

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
Run the following command to edit your credentials:  
```bash
bin/rails encrypted:edit config/credentials.yml.enc
```  
Add the token to your credentials:  
```yaml
trusty_cms:
  page_status_bearer_token: '<your bearer token>'
```  

**3. Create a Ruby Lambda Function in AWS**  
- Log into **AWS Lambda** and create a **new Ruby Lambda function**.  
- Note the **Ruby version** used, as you'll need it locally.  
- Use [rbenv](https://github.com/rbenv/rbenv) to manage the Ruby version locally:  
  ```bash
  rbenv install 3.3.0
  rbenv local 3.3.0
  ```

**4. Write the Lambda Function Code**  
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

**5. Install Dependencies**  
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

**6. Package the Lambda Function**  
Archive your function and dependencies:  
```bash
zip -r lambda_package.zip .
```

**7. Upload to AWS Lambda**  
- In **AWS Lambda**, open your function.  
- Select **Upload From > .zip file**.  
- Upload the `lambda_package.zip` file.  

**8. Configure Environment Variables**  
In the AWS Lambda Configuration: 
- Go to **Environment Variables** > **Edit**.  
- Add the following:  
  - `API_ENDPOINT`: `<your-url>/page-status/refresh`  
  - `BEARER_TOKEN`: `<your bearer token>`  

**9. Set Up EventBridge Trigger**  
- In **Configuration Settings > Triggers**, create a **new EventBridge Trigger**.  
- Set the **Schedule** to match your desired **page status refresh frequency**.  

Your setup is now complete, and **Scheduled Pages** will automatically update their status via the AWS Lambda and EventBridge integration.

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
