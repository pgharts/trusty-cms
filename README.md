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

## Installation and Setup for Use

TrustyCms is a traditional Ruby on Rails application, meaning that you can
configure and run it the way you would a normal Rails application.

See the INSTALL file for more details.

### Installation and Setup for Contributing to TrustyCms

Prerequisites:

* A github account and Git ([Github has some really good instructons](https://help.github.com/articles/set-up-git))
* Ruby 1.9.3
* The bundler gem
* Mysql

1. Fork this repository to your github account.
1. Clone your fork to your machine.
1. Install the gems with bundler: `bundle`
1. Create a database configuration: `cp config/database.mysql.yml config/database.yml`. You probably don't need to make any further changes.
1. Set up your database:

        bundle exec rake db:create
        bundle exec rake db:migrate
        bundle exec rake db:migrate:extensions
1. Run the tests to make sure they pass (If they don't, file a bug!):

        rspec


When you're ready to make a change:

1. Add the pgharts fork as a git remote called "upstream": `git remote add upstream https://github.com/pgharts/trusty-cms.git` so that you can keep up with changes that other people make.
1. Fetch the remote you just added: `git fetch upstream`
1. Start a new branch for the change you're going to make. Name it something having to do with the changes, like "fix-queries" if you are going to try to fix some queries. Base this branch on `upstream/master` by running `git checkout -b fix-queries upstream/master`
1. Make your changes and commit them. Please include tests!
1. Run the tests and make sure they pass.
1. Push your changes to your github fork: `git push origin fix-queries`
1. Send a pull request to the pgharts fork
1. High five the nearest person!


## Support

The best place to get support is on the Pittsburgh Ruby mailing list:

https://groups.google.com/forum/#!forum/rubypgh

Most of the development for TrustyCms happens on Github:

https://github.com/pgharts/trusty-cms

Enjoy!

--
The TrustyCms Dev Team
