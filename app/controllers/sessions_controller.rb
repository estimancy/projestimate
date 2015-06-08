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

#class SessionsController < ApplicationController
#
#  def new
#    #No authorize required since there is nothing to do
#  end
#
#  #Create a session for user if user is authorized
#  def create
#    #No authorize required since everyone can logged in  with (username and password) or LDAP
#
#    user = User.authenticate(params[:username], params[:password])
#    if user
#      if user == 0
#        redirect_to '/dashboard', :flash => {:warning => "#{I18n.t(:warning_invalid_import_from_ldap)} #{I18n.t(:warning_email_or_username_already_exist)} "}
#        return nil
#      end
#      if user == 1
#        redirect_to '/dashboard', :flash => {:warning => "#{I18n.t(:warning_invalid_import_from_ldap)} #{I18n.t(:warning_ldap_attribute_missing, :value => I18n.t(:email_attribute))} "}
#        return nil
#      end
#      if user == 2
#        redirect_to '/dashboard', :flash => {:warning => "#{I18n.t(:warning_invalid_import_from_ldap)} #{I18n.t(:warning_ldap_attribute_missing, :value => I18n.t(:first_name_attribute))} "}
#        return nil
#      end
#      if user == 3
#        redirect_to '/dashboard', :flash => {:warning => "#{I18n.t(:warning_invalid_import_from_ldap)} #{I18n.t(:warning_ldap_attribute_missing, :value => I18n.t(:last_name_attribute))} "}
#        return nil
#      end
#      if user == 4
#        redirect_to '/dashboard', :flash => {:warning => "#{I18n.t(:warning_invalid_import_from_ldap)} #{I18n.t(:warning_ldap_attribute_missing, :value => I18n.t(:user_name_attribute))} "}
#        return nil
#      end
#      if user == 5
#        redirect_to root_url, :notice => "#{I18n.t (:ask_new_account_help)}"
#        return nil
#      end
#      if user.active?
#        if params[:remember_me]
#          cookies[:login] = {:value => user.login_name, :expires => Time.now + 3600}
#        end
#
#        #Last and previous login setting
#        user.update_attribute('previous_login', user.last_login)
#        user.update_attribute('last_login', Time.now)
#
#        #Set current user
#        session[:current_user_id] = user.id
#        session[:ctime] = Time.now.utc.to_i
#        session[:atime] = Time.now.utc.to_i
#        set_user_language
#        #Set current project
#        if user.projects.empty?
#          session[:current_project_id] = nil
#        else
#          session[:current_project_id] = user.projects.first.id
#        end
#        redirect_to params['return_to_url'].nil? ? '/dashboard' : params['return_to_url'], :flash => {:notice => "#{I18n.t (:text_welcome)} "+ user.name}
#
#      else #user.suspended? || user.blacklisted?
#        redirect_to '/dashboard', :flash => {:warning => "#{I18n.t (:warning_account_black_listed)}"}
#      end
#    else
#      redirect_to '/dashboard', :flash => {:warning => "#{I18n.t (:warning_invalid_username_password)}"}
#    end
#  end
#
#  #Logout
#  def destroy
#    #No authorize required since everyone can logout after login
#    session[:current_user_id] = nil
#    redirect_to root_path(:return_to => session[:return_to])
#  end
#
#  #Login
#  def login
#    render :layout => 'login'
#  end
#
#  #Display new account page
#  def ask_new_account
#    #No authorize required since everyone can ask for new account
#    @user = User.new
#  end
#
#  #Display help login page
#  def help_login
#    #No authorize required since everyone can ask for help when logged in
#  end
#
#  #Display "forgotten password" page
#  def forgotten_password
#    #No authorize required since everyone can ask for new password
#  end
#
#  #Reset the password depending of the status of the user
#  def reset_forgotten_password
#    begin
#      user = User.first(:conditions => ['login_name = ? or email = ?', params[:login_name], params[:login_name]])
#      if user
#        if user.auth_method.name == 'Application' or user.auth_method.nil?
#          if user.active?
#            user.send_password_reset if user
#            flash[:notice] = I18n.t(:notice_session_password_reset_instruction)
#            #redirect_to root_url
#          else
#            user.send_password_reset if user
#            flash[:warning] = I18n.t(:warning_session_account_not_active)
#            #redirect_to root_url
#          end
#        else
#          flash[:error] = I18n.t(:error_account_ldap_association)
#          #redirect_to root_url
#        end
#        redirect_to :back
#      else
#        cookies[:login_name] = {:value => params[:login_name], :expires => Time.now + 3600}
#        flash[:warning] = I18n.t(:warning_session_bad_username)
#        render :layout => 'login'
#      end
#    rescue Exception => e
#      flash[:error] = e.message
#      redirect_to :back
#    end
#  end
#
#
#end
