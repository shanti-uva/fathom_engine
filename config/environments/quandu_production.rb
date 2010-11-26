# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# configure to use your institutions mail server
# config.action_mailer.server_settings = { 
#   :address => "domain.of.smtp.host.net", 
#   :port => 25, 
#   :domain => "domain.of.sender.net", 
#   :authentication => :login, 
#   :user_name => "dave", 
#   :password => "secret" 
# } 

config.log_path='/home/sds-deployer/tmp/digitalhumanities/production.log'

# Location of Solr search service
SOLR_URL = 'http://127.0.0.1:8080/dhp-solr' # Search is disabled in production
SSL_ENABLED=true
