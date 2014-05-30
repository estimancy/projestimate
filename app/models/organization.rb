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

#Organization of the User
class Organization < ActiveRecord::Base
  attr_accessible :name, :description, :number_hours_per_day, :number_hours_per_month, :cost_per_hour, :cost_unit

  has_and_belongs_to_many :users
  has_many :wbs_activities, :dependent => :destroy
  has_many :attribute_organizations, :dependent => :destroy
  has_many :organization_technologies, :dependent => :destroy
  has_many :organization_uow_complexities, :dependent => :destroy
  has_many :unit_of_works, :dependent => :destroy
  has_many :pe_attributes, :source => :pe_attribute, :through => :attribute_organizations
  has_many :subcontractors
  has_many :abacus_organizations

  has_many :projects

  #validates_presence_of :name
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :number_hours_per_day, :number_hours_per_month, :cost_per_hour, numericality: { greater_than: 0 }, on: :update, :unless => Proc.new {|organization| organization.number_hours_per_day.nil? || organization.number_hours_per_month.nil? || organization.cost_per_hour.nil? }

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]

  #Override
  def to_s
    self.name
  end
end
