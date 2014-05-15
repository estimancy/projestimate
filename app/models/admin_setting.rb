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
#    ======================================================================
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

# Special table
class AdminSetting < ActiveRecord::Base
  attr_accessible :key, :value, :record_status_id, :custom_value, :change_comment

  include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  validates :record_status, :presence => true
  validates :value, :presence => true, :unless => :is_custom_value_to_consider?
  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :key, :presence => true, :uniqueness => {:scope => :record_status_id, :case_sensitive => false}
  validates :custom_value, :presence => true, :if => :is_custom?

  def is_custom_value_to_consider?
    self.key == 'custom_status_to_consider'
  end


  # function that show the admin_setting value according to the admin_setting key
  def customize_admin_setting_value
    case self.key
      when 'session_maximum_lifetime'
        I18n.t('datetime.distance_in_words.x_days', :count => self.value.to_i)
      when 'session_inactivity_timeout'
        if self.value.to_i==30
          I18n.t('datetime.distance_in_words.x_minutes', :count => (self.value.to_i))
        else
          I18n.t('datetime.distance_in_words.x_hours', :count => self.value.to_i)
        end
      when 'allow_feedback'
        self.value == '1' ? true : false
      when 'audit_history_lifetime'
        setting_value = self.value.split(' ')
        value = setting_value.first
        if setting_value.first == 0
          I18n.t(:label_disabled)
        else
          I18n.t("datetime.distance_in_words.x_#{setting_value.last.to_s.pluralize}", :count => value.to_i)
        end
        # for others keys
      else
        self.value
    end

  end

end
