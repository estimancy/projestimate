# encoding: UTF-8
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

class SizeUnitType < ActiveRecord::Base

  validates :name, :presence => true

  attr_accessible :description, :name, :alias, :organization_id #, :record_status_id, :custom_value, :change_comment

  belongs_to :organization

  has_many :size_unit_type_complexities, dependent: :delete_all
  has_many :technology_size_types
  has_many :organization_technologies, through: :technology_size_types
  has_many :size_units

  #Search fields
  scoped_search :on => [:name, :alias, :description]
end


