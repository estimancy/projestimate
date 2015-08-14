##encoding: utf-8
#class SessionsController < Devise::SessionsController
#  include DeviseSamlAuthenticatable::SamlConfig
#  unloadable if Rails::VERSION::MAJOR < 4
#  before_filter :get_saml_config
#  skip_before_filter :verify_authenticity_token
#
#  def new
#    request = OneLogin::RubySaml::Authrequest.new
#    @action = request.create(@saml_config)
#    #redirect_to @action
#  end
#
#  #def destroy
#  #  if current_user.auth_method.name == "SAML"
#  #    respond_with resource, location: after_sign_out_path_for(resource)
#  #  else
#  #    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
#  #    set_flash_message :notice, :signed_out if signed_out && is_flashing_format?
#  #    yield if block_given?
#  #    respond_to_on_destroy
#  #  end
#  #end
#
#  def create
#    self.resource = warden.authenticate!(auth_options)
#    set_flash_message(:notice, :signed_in) if is_flashing_format?
#    sign_in(resource_name, resource)
#    yield resource if block_given?
#    respond_with resource, location: after_sign_in_path_for(resource)
#  end
#
#  def metadata
#    meta = OneLogin::RubySaml::Metadata.new
#    render :xml => meta.generate(@saml_config)
#  end
#
#  def idp_sign_out
#    if params[:SAMLRequest] && Devise.saml_session_index_key
#      logout_request = OneLogin::RubySaml::SloLogoutrequest.new(params[:SAMLRequest], @saml_config)
#      resource_class.reset_session_key_for(logout_request.name_id)
#
#      redirect_to generate_idp_logout_response(logout_request)
#    elsif params[:SAMLResponse]
#      #Currently Devise handles the session invalidation when the request is made.
#      #To support a true SP initiated logout response, the request ID would have to be tracked and session invalidated
#      #based on that.
#      if Devise.saml_sign_out_success_url
#        redirect_to Devise.saml_sign_out_success_url
#      else
#        redirect_to action: :new
#      end
#    else
#      head :invalid_request
#    end
#  end
#
#  protected
#
#  # Override devise to send user to IdP logout for SLO
#  def after_sign_out_path_for(_)
#    request = OneLogin::RubySaml::Logoutrequest.new
#    request.create(@saml_config)
#  end
#
#  def generate_idp_logout_response(logout_request)
#    logout_request_id = logout_request.id
#    OneLogin::RubySaml::SloLogoutresponse.new.create(@saml_config, logout_request_id, nil)
#  end
#end

class SessionsController < ApplicationController

  def create
    flash[:notice] = "Login Successfully"
    @provider = request.env['omniauth.auth']['provider']
    @uid      = request.env['omniauth.auth']['uid']
    #start a session here, etc!
  end

  def failure
    flash[:notice] = "Auth failure."
  end
end