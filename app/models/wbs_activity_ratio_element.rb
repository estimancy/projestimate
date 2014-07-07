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

class WbsActivityRatioElement < ActiveRecord::Base
  attr_accessible :ratio_value,:simple_reference, :multiple_references, :wbs_activity_ratio_id, :record_status_id, :custom_value, :change_comment, :wbs_activity_element_id

  include MasterDataHelper

  belongs_to :wbs_activity_ratio
  belongs_to :wbs_activity_element

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  has_many :wbs_activity_ratio_profiles

  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  #validates :ratio_value, :numericality => { :greater_than => 0, :less_than => 100 }

  #Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable

    customize(lambda { |original_wbs_activity_ratio_elt, new_wbs_activity_ratio_elt|

      if defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
        new_wbs_activity_ratio_elt.record_status_id = RecordStatus.find_by_name('Proposed').id
      else
        new_wbs_activity_ratio_elt.record_status_id = RecordStatus.find_by_name('Local').id
      end

    })

  end
end
