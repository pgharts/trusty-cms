require 'acts_as_list'
require 'uuidtools'
require 'trusty_cms_clipped_extension/cloud'
require 'active_storage/engine'
require 'will_paginate/array'
module Clipped
  class Engine < Rails::Engine
    paths["app/helpers"] = []

  end
end
