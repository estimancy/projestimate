#encoding: utf-8
#############################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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

class UserObserver < ActiveRecord::Observer
  observe User

  def after_update(user)
    if user.user_status_changed?
      if user.suspended? || user.pending? || user.blacklisted?
        UserMailer.account_suspended(user).deliver
      else
        if user.password.blank?
          if user.auth_method.nil?
            UserMailer.account_validate(user).deliver
          elsif user.auth_method.name == "Application"
            UserMailer.account_validate(user).deliver
          else
            UserMailer.account_validate_ldap(user).deliver
          end
        else
          UserMailer.account_validate_no_pw(user).deliver
        end
      end
    end
  end

end