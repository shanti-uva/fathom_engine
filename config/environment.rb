# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_shanti_session',
    :secret      => 'c3504ee7ee96612efd0c8ed2ebf53ee7de5a6278fab6d63c11ff66984320e012794e4c185d870b7c834812eaa469c27aaa58d51c9e32f130534fc62d2939bc52'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  config.gem 'mislav-will_paginate', :version => '~> 2.3.8', :lib => 'will_paginate',
    :source => 'http://gems.github.com'

  #RedCloth - converts plain text or textile to HTML (also used by HAML)
  config.gem "RedCloth", :lib=>"redcloth", :version => "~> 3.0.4"

  #Solr-Ruby - Solr connections for Ruby
  config.gem "solr-ruby", :lib => "solr", :version => "~> 0.0.7"
end

require 'will_paginate'

APPLICATION_DOMAIN = 'shanti.virginia.edu'

# Target e-mails for exception handling.
FATHOM_NO_REPLY_ADDRESS = 'shanticontact@collab.itc.virginia.edu'
FATHOM_CONTACT_ADDRESS = FATHOM_NO_REPLY_ADDRESS
ExceptionNotifier.sender_address = %Q("Application Error" <#{FATHOM_NO_REPLY_ADDRESS}>)
ExceptionNotifier.exception_recipients = %w(ys2n@virginia.edu)
