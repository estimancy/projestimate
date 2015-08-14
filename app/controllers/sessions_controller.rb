#encoding: utf-8
class SessionsController < Devise::SessionsController
  def new

    #OneLogin::RubySaml::Logging.logger = Logger.new(File.open('/var/log/ruby-saml.log', 'w')

    unless params["SAMLResponse"].nil?

      response = OneLogin::RubySaml::Response.new(params["SAMLResponse"])

      if response.is_valid?
        logger.info "Réponse valide"
      end
      logger.info response.inspect

      #session[:userid] = response.nameid
      #session[:attributes] = response.attributes

      @user = User.find_for_saml_oauth(response.attributes, current_user)
      if @user.persisted?
        sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
        set_flash_message(:notice, :success, :kind => "SNCF SAML") if is_navigational_format?
      else
        redirect_to new_user_registration_url
      end
      #session[:important_data] = params.merge(request.env["omniauth.auth"])
      #@important_data = params.merge(request.env["omniauth.auth"])
    else
      super
    end
  end
end