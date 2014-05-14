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
#    ===================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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

#encoding: utf-8
class PasswordResetsController < ApplicationController
  layout 'login'

  #Edit the new password, checks token validity
  def edit
    begin
      @user = User.find_by_password_reset_token!(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      @user = nil
      flash[:error] = I18n.t(:record_not_found_password_reset_token)
      redirect_to root_path
    end
  end

  #Update the new password
  def update
    @user = User.find_by_password_reset_token!(params[:id])

    if @user.password_reset_sent_at < 2.hours.ago
      UserMailer.new_password(@user).deliver
      redirect_to new_password_reset_path, :error => "#{I18n.t (:warning_reset_password_expired)}"
    elsif @user.update_attributes(params[:user])
      UserMailer.new_password(@user).deliver
      redirect_to root_path, :notice => "#{I18n.t (:notice_password_successful_reset)}"
    else
      render :edit
    end
  end

end

