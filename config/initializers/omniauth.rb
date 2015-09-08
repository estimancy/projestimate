CERTIFICATE =<<CERTIFICATE
-----BEGIN CERTIFICATE-----
MIIDFDCCAfygAwIBAgIEVLPsKDANBgkqhkiG9w0BAQ0FADBMMQswCQYDVQQGEwJGUjENMAsGA1UE CgwEU05DRjENMAsGA1UECwwERFNJVDEfMB0GA1UEAwwWaWRwLXNpZ25hdHVyZS0yMDE0LWRldjAe Fw0xNTAxMTIxNTQ2NThaFw0yNTAxMTIxNTQ2NThaMEwxCzAJBgNVBAYTAkZSMQ0wCwYDVQQKDART TkNGMQ0wCwYDVQQLDAREU0lUMR8wHQYDVQQDDBZpZHAtc2lnbmF0dXJlLTIwMTQtZGV2MIIBIjAN BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArV7qnTenVeZwYP4m0ji5xbsFvqNRTW8+i0Ys98oB VKlWJpEXdPUQMBi4TdjHPUBRmueW74v1v8Uw+1NeE8WvI0bStvH7P2zxeP5bdL6onVNIZUdb1L1l kBjlYQP30TtsRZuJ2d+vmf3BKEvtd3V47A8gSuAJO9q8dT+Rby7ZOMWw/ZU/dJTIGplhgpJlQMXi 3wLZyHU+oi7V5PmRE0ZYEn0LLXtQXQj1bYW+5AjU6TykXQVqISqImGiONpnKQYkOgZ56vXR9nU+/ ZSmyc/VTBTnA0Xwj/aWfOokaFqft0LhH1gykhq9IIgHaxo55SqRm4lymxx13Hpe1lA3BlWzWVQID AQABMA0GCSqGSIb3DQEBDQUAA4IBAQCisxQCBp26pa52WPq5l0srOO6kfq0oNi/6IWKlQQF0p8MV gsH+ITyHd59h5b5JXXUirL+FzpTHiabLVcSkA2rG+jfuqCGTMtXZiANUEkmlNa8NAmDHwOPe19fL SFl7duFE5BacS4IYf6zPFkpMNBMBJdQlud+chuiKpdYQanSN2Vr+ZEUQlYddkUFZUGIKpw3LpwRP dSdxoqNyHr4u+j5yOXWzaRtZpaw7zMPNT+YAB6shmpVSsbwJ1xRE34t1hj3UV/44XnnvXWCqUjsp yUje5NYfEh8ehf5Ysv6kToXM9fTyKWJhx+ip/lnSIzNe1bFjGXesSmYGtapu6htcLF2m
-----END CERTIFICATE-----
CERTIFICATE

Rails.application.config.middleware.use OmniAuth::Builder do
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