# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

#require 'database_cleaner'
#require "codeclimate-test-reporter"
#CodeClimate::TestReporter.start

#require 'coveralls'
#Coveralls.wear!('rails')

require 'simplecov'

#SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
#    Coveralls::SimpleCov::Formatter,
#    SimpleCov::Formatter::HTMLFormatter,
#    CodeClimate::TestReporter::Formatter
#]

SimpleCov.start 'rails' do
  SimpleCov.merge_timeout 3600
end

require 'uuidtools'
require 'csv'

require 'spork'

Spork.prefork do
  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'capybara/rspec'
  require 'factory_girl'
  require "cancan/matchers"

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  require Rails.root.join("spec/support/controller_helpers.rb")
end

Spork.each_run do
  load "#{Rails.root}/config/routes.rb"
  Dir["#{Rails.root}/app/**/*.rb"].each {|f| load f}
  Dir["#{Rails.root}/lib/**/*.rb"].each {|f| load f}

  require Rails.root.join("app/controllers/application_controller")

  # This code will be run each time you run your specs.
  RSpec.configure do |config|

    config.mock_with :rspec

    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = false  ###true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Run specs in random order to surface order dependencies. If you find an
    # order dependency and want to debug it, you can fix the order by providing
    # the seed, which is printed after each run.
    #     --seed 1234
    config.order = "random"

    config.infer_spec_type_from_file_location!

    #Render views globally
    config.render_views

    # For cleaning test database
    config.include DatabaseCleaner

    #Manage user authentication on test
    config.include Devise::TestHelpers, :type => :controller
    config.include Warden::Test::Helpers
    config.include ControllerHelpers, :type => :controller

    ##For taking in account the Permissions with the CanCan gem
    #config.extend(ControllerSpecs::CanCan, type: :controller)

  end
end
