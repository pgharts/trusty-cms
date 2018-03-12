require 'acts_as_list'
require 'uuidtools'
require 'trusty_cms_clipped_extension/cloud'
require 'paperclip'
require 'will_paginate/array'
module Clipped
  class Engine < Rails::Engine
    paths["app/helpers"] = []

  end
end
