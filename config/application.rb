#encoding: utf-8
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
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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

require File.expand_path('../boot', __FILE__)

require 'csv'
require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Projestimate
  class Application < Rails::Application

    config.reload_plugins = true

    config.autoload_paths += Dir["#{config.root}/vendor/gems/cocomo_basic/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/cocomo_advanced/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/cocomo_expert/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/uow/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/guw/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/real_size/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/expert_judgment/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/effort_breakdown/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/wbs_activity_completion/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/sample_model/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/sandbox/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/effort_balancing/lib"]
    config.autoload_paths += Dir["#{config.root}/vendor/gems/initialization/lib"]

    config.autoload_paths += %W(#{config.root}/vendor/gems/cocomo_basic/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/cocomo_advanced/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/cocomo_expert/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/uow/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/guw/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/real_size/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/expert_judgment/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/effort_breakdown/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/wbs_activity_completion/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/sample_model/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/sandbox/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/effort_balancing/lib)
    config.autoload_paths += %W(#{config.root}/vendor/gems/effort_balancing/app)
    config.autoload_paths += %W(#{config.root}/vendor/gems/initialization/lib)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths << File.join(config.root, "lib")

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    config.active_record.observers = :user_observer, :module_project_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('locales','devise','*.{rb,yml}').to_s]
    config.i18n.load_path += Dir[Rails.root.join('locales','simple_form','*.{rb,yml}').to_s]
    config.i18n.default_locale = :fr

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    config.assets.paths << Rails.root.join("app", "assets", "font")

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    #config.force_ssl = true

    # these lines go within the Application class definition
    config.generators do |g|
      g.test_framework :rspec, :fixture => true, :views => false, :fixture_replacement => :factory_girl, :view_specs => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    # Global constante declaration
    ALPHABETICAL = %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
    INITIALIZATION = "initialization"
    EFFORT_PERSON_HOUR = "effort_person_hour"
    EFFORT = "effort"
    EFFORT_PERSON_WEEK = "effort_person_week"
    DELAY = "delay"
    STAFFING = "staffing"
    COST = "cost"


    # Modules with Factors
    COCOMO_ADVANCED = "cocomo_advanced"
    COCOMO_INTERMEDIATE = "cocomo_advanced"
    COCOMO_EXPERT = "cocomo_expert"
    COCOMO_II = "cocomo_expert"
    MODULES_WITH_FACTORS = [COCOMO_INTERMEDIATE, COCOMO_ADVANCED, COCOMO_II, COCOMO_EXPERT]

    EFFORT_BALANCING = "effort_balancing"
    EFFORT_BREAKDOWN = "effort_breakdown"
    SIZE_BALANCING = "size_balancing"
    BALANCING_MODULE = "balancing_module"
    BALANCING_MODULES_NAME = [ EFFORT_BALANCING, SIZE_BALANCING ]

    # icones for widgets
    #ICON_CLASSES = ["icon-euro", "icon-usd", "icon-gbp", "icon-user", "icon-users", "icon-user-md", "icon-bell", "fa fa-clock-o", "icon-dashboard", "icon-calendar", "icon-bug", " icon-bomb", "icon-warning", "icon-line-chart", "icon-pie-chart", "icon-area-chart", "icon-bar-chart"]
    ICON_CLASSES = ["icon-euro", "icon-usd", "icon-gbp", "fa-money", "icon-user", "icon-group", "icon-time", "icon-bell", "icon-calendar", "icon-eye-open", "icon-eye-close", "fa-bomb", "icon-bug", "icon-warning-sign", "icon-exclamation-sign", "icon-question-sign", "icon-fire", "fa-minus-circle", "icon-arrow-right", "icon-arrow-up", "icon-arrow-down", "icon-share-alt", "icon-comment", "icon-dashboard", "fa-wrench", "fa-cog", "fa-cogs", "fa-database", "fa-home", "fa-info", "fa-line-chart", "fa-pie-chart", "fa-area-chart", "fa-bar-chart"]

  end
end
