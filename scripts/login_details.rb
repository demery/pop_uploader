#!/usr/bin/env ruby

require 'flickraw'

FlickRaw.api_key       = ENV['POP_FLICKR_API_KEY']
FlickRaw.shared_secret = ENV['POP_FLICKR_API_SECRET']

flickr.access_token    = ENV['POP_FLICKR_ACCESS_TOKEN']
flickr.access_secret   = ENV['POP_FLICKR_ACCESS_SECRET']

# From here you are logged:
login = flickr.test.login
puts "You are now authenticated as #{login.inspect}"
