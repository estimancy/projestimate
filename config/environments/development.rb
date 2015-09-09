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

#require 'openssl'

Projestimate::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make codefalse changes.
  config.cache_classes = false

  config.reload_plugins = true

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = false

  config.action_mailer.delivery_method = :smtp

  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_controller.perform_caching = true

  #Default URL option
  config.action_mailer.default :charset => "utf-8"

  config.action_mailer.default_url_options = { host: APP_CONFIG['HOST_URL'] }

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