#encoding: utf-8
class SessionsController < Devise::SessionsController

  def new
    unless params["SAMLResponse"].nil?

      response = OneLogin::RubySaml::Response.new(params["SAMLResponse"])

      #if response.is_valid?
      #  logger.info "Réponse valide"
      #end
      #logger.info response.inspect

      #session[:userid] = response.nameid
      #session[:attributes] = response.attributes

      @user = User.find_for_saml_oauth(response.attributes)
      if @user.nil?
        flash[:warning] = I18n.t("error_access_denied")
        redirect_to root_url
      else
        sign_in_and_redirect @user, :event => :authentication
        set_flash_message(:notice, :success, :kind => "SNCF SAML") if is_navigational_format?
      end
    else
      super
    end
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    if resource.auth_method.name == "Application"
      set_flash_message(:notice, :signed_in) if is_flashing_format?
      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      flash[:warning] = "Ce compte est associé à une authentification externe"
      sign_out resource
      redirect_to root_url
    end
  end
end