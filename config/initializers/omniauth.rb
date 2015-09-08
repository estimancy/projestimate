#OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :saml,
           :assertion_consumer_service_url     => APP_CONFIG['ASSERTION_CONSUMER_SERVICE_URL'],
           :issuer                             => APP_CONFIG['ISSUER'],
           :idp_sso_target_url                 => APP_CONFIG['IDP_SSO_TARGET_URL'],
           :idp_sso_target_url_runtime_params  => {:original_request_param => :mapped_idp_param},
           :idp_cert                           => APP_CONFIG['CERTIFICATE'],
           #:idp_cert_fingerprint               => "E7:91:B2:E1:...",
           #:idp_cert_fingerprint_validator     => lambda { |fingerprint| fingerprint },
           :name_identifier_format             => APP_CONFIG['NAME_IDENTIFIER_FORMAT']
end