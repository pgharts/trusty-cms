## Welcome to TrustyCMS

Trusty is a branch of the venerable TrustyCms CMS. Its goal is to pull the TrustyCms framework into Rails 3 with minimal changes to its infrastructure. Everything below this is from the TrustyCms readme.

TrustyCms is a no-fluff, open source content management system designed for
small teams. It is similar to Textpattern or MovableType, but is a general
purpose content management system (not just a blogging engine).

[![Build Status](https://secure.travis-ci.org/pgharts/trusty-cms.png?branch=master)](https://travis-ci.org/pgharts/trusty-cms/)

TrustyCms features:

* An elegant user interface
* The ability to arrange pages in a hierarchy
* Flexible templating with layouts, snippets, page parts, and a custom tagging
  language (Radius: http://radius.rubyforge.org)
* A simple user management/permissions system
* Support for Markdown and Textile as well as traditional HTML (it's easy to
  create other filters)
* An advanced plugin system
* Operates in two modes: dev and production depending on the URL
* A caching system which expires pages every 5 minutes
* Built using Ruby on Rails
* And much more...

## License

TrustyCms is released under the MIT license. The Radiant portions of the
codebase are copyright (c) John W. Long and Sean Cribbs; anything after the
fork is copyright (c) Pittsburgh Cultural Trust. A copy of the MIT license can
be found in the LICENSE file.

## Installation and Setup

TrustyCms is a traditional Ruby on Rails application, meaning that you can
configure and run it the way you would a normal Rails application.

See the INSTALL file for more details.

### Installation of a Prerelease

As TrustyCms nears newer releases, you can experiment with any prerelease version.

Install the prerelease gem with the following command:

    $ gem install radiant --prerelease

This will install the gem with the prerelease name, for example: ‘radiant-0.9.0.rc2’.

### Upgrading an Existing Project to a newer version

1. Update the TrustyCms assets from in your project:

    $ rake radiant:update

2. Migrate the database:

    $ rake production db:migrate

3. Restart the web server

## Development Requirements

To run tests you will need to have the following gems installed:

  gem install ZenTest rspec rspec-rails cucumber webrat nokogiri sqlite3-ruby

## Support

The best place to get support is on the mailing list:

http://radiantcms.org/mailing-list/

Most of the development for TrustyCms happens on Github:

https://github.com/pgharts/trusty-cms

Enjoy!

--
The TrustyCms Dev Team
