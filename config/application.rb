require File.expand_path('../boot', __FILE__)

if defined?(Bundler)
  Bundler.require(:default, ENV['RACK_ENV'].to_sym)
end

require "socket"
require 'active_support/all'
require 'resource'
require 'has_mbean'
require 'torquebox_managed'
require 'destinations/models/destination'
require 'destinations/models/queue'
require 'destinations/models/topic'
require 'destinations/models/message'
require 'zabbix_sender'
require 'torquebox_stats_monitor'
