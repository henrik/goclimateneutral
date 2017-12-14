# This file is used by Rack-based servers to start the application.

require_relative 'config/environment'

use Rack::ReverseProxy do  
    # Set :preserve_host to true globally (default is true already)
    reverse_proxy_options preserve_host: true

    # Forward the path /test* to http://example.com/test*
    reverse_proxy /^\/blog(\/.*)$/, 'http://goclimateneutral.nilver.se$1'
    reverse_proxy /^\/wp-admin/(\/.*)$/, 'http://goclimateneutral.nilver.se/wp-admin$1'
    
end

run Rails.application