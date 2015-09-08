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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

Projestimate::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to Rails.root.join("public/assets")
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  #default url
  config.action_mailer.default_url_options = { host: APP_CONFIG['HOST_URL'] }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  CERTIFICATE =<<CERTIFICATE
-----BEGIN CERTIFICATE-----
MIIDFDCCAfygAwIBAgIEVLPsKDANBgkqhkiG9w0BAQ0FADBMMQswCQYDVQQGEwJGUjENMAsGA1UE CgwEU05DRjENMAsGA1UECwwERFNJVDEfMB0GA1UEAwwWaWRwLXNpZ25hdHVyZS0yMDE0LWRldjAe Fw0xNTAxMTIxNTQ2NThaFw0yNTAxMTIxNTQ2NThaMEwxCzAJBgNVBAYTAkZSMQ0wCwYDVQQKDART TkNGMQ0wCwYDVQQLDAREU0lUMR8wHQYDVQQDDBZpZHAtc2lnbmF0dXJlLTIwMTQtZGV2MIIBIjAN BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArV7qnTenVeZwYP4m0ji5xbsFvqNRTW8+i0Ys98oB VKlWJpEXdPUQMBi4TdjHPUBRmueW74v1v8Uw+1NeE8WvI0bStvH7P2zxeP5bdL6onVNIZUdb1L1l kBjlYQP30TtsRZuJ2d+vmf3BKEvtd3V47A8gSuAJO9q8dT+Rby7ZOMWw/ZU/dJTIGplhgpJlQMXi 3wLZyHU+oi7V5PmRE0ZYEn0LLXtQXQj1bYW+5AjU6TykXQVqISqImGiONpnKQYkOgZ56vXR9nU+/ ZSmyc/VTBTnA0Xwj/aWfOokaFqft0LhH1gykhq9IIgHaxo55SqRm4lymxx13Hpe1lA3BlWzWVQID AQABMA0GCSqGSIb3DQEBDQUAA4IBAQCisxQCBp26pa52WPq5l0srOO6kfq0oNi/6IWKlQQF0p8MV gsH+ITyHd59h5b5JXXUirL+FzpTHiabLVcSkA2rG+jfuqCGTMtXZiANUEkmlNa8NAmDHwOPe19fL SFl7duFE5BacS4IYf6zPFkpMNBMBJdQlud+chuiKpdYQanSN2Vr+ZEUQlYddkUFZUGIKpw3LpwRP dSdxoqNyHr4u+j5yOXWzaRtZpaw7zMPNT+YAB6shmpVSsbwJ1xRE34t1hj3UV/44XnnvXWCqUjsp yUje5NYfEh8ehf5Ysv6kToXM9fTyKWJhx+ip/lnSIzNe1bFjGXesSmYGtapu6htcLF2m
-----END CERTIFICATE-----
CERTIFICATE
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  config.middleware.use OmniAuth::Builder do
    provider :saml,
             :assertion_consumer_service_url     => APP_CONFIG['ASSERTION_CONSUMER_SERVICE_URL'],
             :issuer                             => APP_CONFIG['ISSUER'],
             :idp_sso_target_url                 => APP_CONFIG['IDP_SSO_TARGET_URL'],
             :idp_sso_target_url_runtime_params  => {:original_request_param => :mapped_idp_param},
             :idp_cert                           => CERTIFICATE,
             #:idp_cert_fingerprint               => "E7:91:B2:E1:...",
             #:idp_cert_fingerprint_validator     => lambda { |fingerprint| fingerprint },
             :name_identifier_format             => APP_CONFIG['NAME_IDENTIFIER_FORMAT']
  end

end
