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

# app/controllers/registrations_controller.rb
class RegistrationsController < Devise::RegistrationsController

  def new
    if session["devise.user_attributes"]
      if !session["devise.user_attributes"]['provider'].nil? && session["devise.user_attributes"]['uid'].nil?
        @firstname_with_provider = session["devise.user_attributes"]['first_name']
        @lastname_with_provider = session["devise.user_attributes"]['last_name']
        @login_name_with_provider = session["devise.user_attributes"]['login_name']
        @email_with_provider = session["devise.user_attributes"]['email']
      end
    end

    super
  end

  def create
    super do |resource|
      resource.initials = "your_initials"
      auth_type = AuthMethod.find_by_name('Application')
      @defined_record_status = RecordStatus.find_by_name('Defined')
      everyone_group = Group.find_by_name_and_record_status_id("Everyone", @defined_record_status)
      resource.auth_type = auth_type.nil? ? nil : auth_type.id
      resource.groups << everyone_group
      resource.user_status = status
      resource.save
    end
  end

  def update
    #super do |resource|
    #  #resource.save
    #  #redirect_to edit_user_path(current_user)
    #end
    super
  end

  private

  def is_an_automatic_account_activation?
    #No authorize required since this method is protected and won't be call from any route
    begin
      AdminSetting.where(:record_status_id => RecordStatus.find_by_name('Defined').id, :key => 'self-registration').first.value == 'automatic account activation'
    rescue
      false
    end
  end

end