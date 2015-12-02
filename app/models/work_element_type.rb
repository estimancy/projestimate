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

#Master Data
#WorkElementType has many pbs_project_elements and belongs to project_area. WET can be "development", "cots" but also "folder" and "link"
class WorkElementType < ActiveRecord::Base
  attr_accessible :alias, :name, :description, :organization_id#, :record_status_id, :custom_value, :change_comment

  #include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  has_many :pbs_project_elements#, :dependent => :destroy

  #belongs_to :record_status
  #belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  belongs_to :project_area
  belongs_to :organization

  #validates :record_status, :presence => true
  validates :name, :alias, :presence => true#, :uniqueness => {:case_sensitive => false, :scope => :record_status_id}
  #validates :custom_value, :presence => true, :if => :is_custom?

  #Search fields
  scoped_search :on => [:name, :alias, :description, :created_at, :updated_at]

  def self.work_element_type_list
    Object::WorkElementType.all.map(&:alias)
  end

  #Override
  def to_s
    name
  end
end
