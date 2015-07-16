#encoding: utf-8
class SessionsController < Devise::SessionsController
  include DeviseSamlAuthenticatable::SamlConfig
  unloadable if Rails::VERSION::MAJOR < 4
  before_filter :get_saml_config
  skip_before_filter :verify_authenticity_token

  def new
    request = OneLogin::RubySaml::Authrequest.new
    @action = request.create(@saml_config)
  end

  def destroy
    if current_user.auth_method.name == "SAML"
      respond_with resource, location: after_sign_out_path_for(resource)
    else
      super
    end
  end

  # POST /resource/sign_in
  def create
    if current_user.auth_method.name == "Application"
      self.resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      sign_out
      redirect_to root_url
    end
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(@saml_config)
  end

  protected
  # Override devise to send user to IdP logout for SLO
  def after_sign_out_path_for(_)
    request = OneLogin::RubySaml::Logoutrequest.new
    request.create(@saml_config)
  end

end
