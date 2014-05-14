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
    super
  end

  def create
    super do |resource|
      resource.initials = "your_initials"
      auth_type = AuthMethod.find_by_name('Application')
      @defined_record_status = RecordStatus.find_by_name('Defined')
      everyone_group = Group.find_by_name_and_record_status_id("Everyone", @defined_record_status)
      # Add default Authentication method and group to user
      resource.auth_type = auth_type.nil? ? nil : auth_type.id
      resource.groups << everyone_group
      is_an_automatic_account_activation? ? status = 'active' : status = 'pending'

      resource.user_status = status
      resource.save
    end
  end

  def update
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