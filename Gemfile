source 'http://rubygems.org'
source 'http://gems.rubyforge.org'
source 'http://gemcutter.org'

gem 'rails', '3.1.3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-datatables-rails'
  gem 'jquery-ui-rails'
end

gem 'jquery-rails'

group :test do
  gem 'factory_girl_rails', '~> 4.0'
  gem 'capybara'
  #To satisfy

  # rspec goodies
  gem 'rspec-rails', :group => [:test, :development]

  # DRb server for testing frameworks
  gem 'spork'

 # command line tool to easily handle events on file system modifications
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-spork'
  gem 'guard-migrate'
  gem 'guard-rake'

  #Coverage tool
  gem 'simplecov', :require => false, :group => :test

  # run some required services using foreman start, more on this at the end of the article
  gem 'foreman'
end

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', :require => 'bcrypt'

#Databases
gem 'mysql2'
gem 'mysql'
#gem 'pg'

#Translations
gem 'globalize3'

#Permissions
gem 'cancan'

#Tree
gem 'ancestry'

#LDAP
gem 'activedirectory'
gem 'net-ldap'

# Web server
gem 'unicorn'
#gem 'passenger'

group :development do
#  gem 'mongrel'

  #For UML classes diagram generator
  gem 'railroady', :group => [:development, :test]
end

# Deploy with Capistrano
gem 'capistrano'

#Others
gem 'will_paginate'
gem 'will_paginate-bootstrap'

# To use debugger
#gem 'ruby-debug19', :require => 'ruby-debug'

#Searching
gem 'sunspot_rails'
gem 'sunspot_solr'

#Workflow
gem 'aasm'

#Advanced form
gem 'simple_form'

#Dataepicker bootsrap theme
gem 'bootstrap-datepicker-rails'

#Icon management
gem 'paperclip', '~> 3.0'

#Continious integration and monitoring
gem 'newrelic_rpm'


