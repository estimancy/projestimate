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
  attr_accessible :name, :description, :number_hours_per_day, :number_hours_per_month, :cost_per_hour, :currency_id, :inflation_rate, :limit1, :limit2, :limit3

  #has_and_belongs_to_many :users
  #Groups created on local, will be attached to an organization
  has_many :groups
  has_many :users, through: :groups

  has_many :wbs_activities, :dependent => :destroy
  has_many :attribute_organizations, :dependent => :destroy
  has_many :pe_attributes, :source => :pe_attribute, :through => :attribute_organizations

  has_many :organization_technologies, :dependent => :destroy
  has_many :organization_uow_complexities, :dependent => :destroy
  has_many :unit_of_works, :dependent => :destroy
  has_many :subcontractors, :dependent => :destroy
  has_many :projects
  has_many :organization_profiles, :dependent => :destroy
  has_many :profile_categories
  has_many :size_unit_types
  has_many :technology_size_types, :through => :size_unit_types

  #Estimations statuses
  has_many :estimation_statuses, :dependent => :destroy
  has_many :estimation_status_group_roles, :through => :estimation_statuses
  ###has_many :status_transitions, :through => :estimation_statuses

  belongs_to :currency
  #validates_presence_of :name
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :number_hours_per_day, :number_hours_per_month, :cost_per_hour, numericality: { greater_than: 0 }   ###, on: :update, :unless => Proc.new {|organization| organization.number_hours_per_day.nil? || organization.number_hours_per_month.nil? || organization.cost_per_hour.nil? }
  validates :currency_id, :presence => true
  validates_presence_of :limit1, :limit2, :limit3

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]

  #Override
  def to_s
    name
  end

  # Get master defined groups and organization's groups
  def organization_groups
    (Group.defined.all + self.groups.all).flatten
  end


  # Add the amoeba gem for the copy
  amoeba do
    enable
    #include_field [:attribute_organizations, :organization_technologies, :organization_profiles, :unit_of_works, :subcontractors, :size_unit_types, :technology_size_types, :abacus_organizations, :organization_uow_complexities, :estimation_statuses]
    include_field [:pe_attributes, :organization_technologies, :organization_profiles, :unit_of_works, :subcontractors, :technology_size_types, :organization_uow_complexities, :estimation_statuses, :groups]

    customize(lambda { |original_organization, new_organization|
      new_organization.name = "Copy of '#{original_organization.name}' at #{Time.now}"
    })
    propagate
  end

end
