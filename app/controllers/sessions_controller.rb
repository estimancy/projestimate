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
        redirect_to new_user_registration_url
      else
        sign_in_and_redirect @user, :event => :authentication
        set_flash_message(:notice, :success, :kind => "SNCF SAML") if is_navigational_format?
      end
    else
      super
    end
  end
end