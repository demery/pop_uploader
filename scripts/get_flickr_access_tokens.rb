require 'flickraw'

# FlickRaw.api_key="... Your API key ..."
# FlickRaw.shared_secret="... Your shared secret ..."

# token = flickr.get_request_token
# auth_url = flickr.get_authorize_url(token['oauth_token'], :perms => 'delete')

# puts "Open this url in your process to complete the authication process : #{auth_url}"
# puts "Copy here the number given when you complete the process."
# verify = gets.strip

# begin
#   flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
#   login = flickr.test.login
#   puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
# rescue FlickRaw::FailedResponse => e
#   puts "Authentication failed : #{e.msg}"
# end

# # POP official Flickr site
# # export POP_FLICKR_KEY=52abd31ab773601d488288ef195bbc81
# # export POP_FLICKR_SECRET=b13d80e197d03e03

# # Below are the dev site keys
# export POP_FLICKR_API_KEY=23ae28decf83a0471ba61ca6817a5958
# export POP_FLICKR_API_SECRET=aca944783a025427
# export POP_FLICKR_ACCESS_TOKEN=72157648589386923-cef08493bc6abb92
# export POP_FLICKR_ACCESS_SECRET=3bdcbb29d5349f40

# export POP_FLICKR_USERID=130616888@N02



FlickRaw.api_key       = ENV['POP_FLICKR_API_KEY']
FlickRaw.shared_secret = ENV['POP_FLICKR_API_SECRET']

token                  = flickr.get_request_token
auth_url               = flickr.get_authorize_url(token['oauth_token'], perms: 'delete')

puts "Open this url in your process to complete the authication process : #{auth_url}"
puts "Copy here the number given when you complete the process."
verify = gets.strip

begin
  flickr.get_access_token(token['oauth_token'], token['oauth_token_secret'], verify)
  login = flickr.test.login
  puts "You are now authenticated as #{login.username} with token #{flickr.access_token} and secret #{flickr.access_secret}"
rescue FlickRaw::FailedResponse => e
  puts "Authentication failed : #{e.msg}"
end
