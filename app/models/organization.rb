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

class QueryColumn
  attr_accessor :name, :caption, :association_name

  def initialize(name, options={})
    self.name = name
    #self.association_name = association_name
    self.caption = options[:caption]
  end

  def value(object)
    object.send name
  end

  def value_object(object)
    object.send name
  end

  def css_classes
    name
  end
end


#Organization of the User
class Organization < ActiveRecord::Base
  attr_accessible :name, :description, :is_image_organization, :number_hours_per_day, :number_hours_per_month, :cost_per_hour, :currency_id, :inflation_rate,
                  :limit1, :limit2, :limit3, :limit4,
                  :limit1_coef, :limit2_coef, :limit3_coef, :limit4_coef,
                  :limit1_unit, :limit2_unit, :limit3_unit, :limit4_unit


  serialize :project_selected_columns, Array

  #has_and_belongs_to_many :users
  #Groups created on local, will be attached to an organization
  has_many :groups, :dependent => :destroy
  #has_many :users, through: :groups, uniq: true
  ###has_and_belongs_to_many :users   ##to comment if not working

  #For user without group
  has_many :organizations_users, class_name: 'OrganizationsUsers', :dependent => :destroy
  has_many :users, through: :organizations_users#, :source => :user, uniq: true

  has_many :fields, :dependent => :destroy
  has_many :wbs_activities, :dependent => :destroy
  has_many :attribute_organizations, :dependent => :delete_all
  has_many :pe_attributes, :source => :pe_attribute, :through => :attribute_organizations

  has_many :organization_technologies, :dependent => :destroy
  has_many :organization_uow_complexities, :dependent => :destroy
  has_many :unit_of_works, :dependent => :destroy
  has_many :projects, :dependent => :destroy
  has_many :module_projects, through: :projects

  has_many :organization_profiles, :dependent => :destroy
  has_many :size_unit_types, :dependent => :destroy
  has_many :technology_size_types, :through => :size_unit_types

  #Estimations statuses
  has_many :estimation_statuses, :dependent => :destroy
  has_many :status_transitions, :through => :estimation_statuses
  has_many :estimation_status_group_roles, :through => :estimation_statuses

  #Guw Model
  has_many :guw_models, class_name: "Guw::GuwModel", dependent: :destroy
  has_many :ge_models, class_name: "Ge::GeModel", dependent: :destroy
  has_many :amoa_models, class_name: "Amoa::AmoaModel", dependent: :destroy
  has_many :expert_judgement_instances, class_name: "ExpertJudgement::Instance", dependent: :destroy

  has_many :project_areas, dependent: :destroy
  has_many :project_categories, dependent: :destroy
  has_many :platform_categories, dependent: :destroy
  has_many :acquisition_categories, dependent: :destroy

  has_many :work_element_types, dependent: :destroy

  has_many :project_security_levels, dependent: :destroy

  # Results view
  has_many :views

  belongs_to :currency
  #validates_presence_of :name
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :number_hours_per_month, :cost_per_hour, numericality: { greater_than: 0 }   ###, on: :update, :unless => Proc.new {|organization| organization.number_hours_per_day.nil? || organization.number_hours_per_month.nil? || organization.cost_per_hour.nil? }
  validates :currency_id, :presence => true
  validates_presence_of :limit1, :limit2, :limit3

  #Search fields
  scoped_search :on => [:name, :description, :created_at, :updated_at]

  #Override
  def to_s
    name
  end

  # Add the amoeba gem for the copy
  amoeba do
    enable
    include_association [:project_areas, :project_categories, :platform_categories, :acquisition_categories,
                         :work_element_types, :attribute_organizations, :organization_technologies,
                         :organization_profiles, :unit_of_works, :size_unit_types, :technology_size_types,
                         :organization_uow_complexities, :fields, :groups, :project_security_levels,
                         :estimation_statuses, :guw_models, :ge_models, :expert_judgement_instances]

    customize(lambda { |original_organization, new_organization|
      new_copy_number = original_organization.copy_number.to_i+1
      new_organization.name = "#{original_organization.name}(#{new_copy_number})" ###"Copy of '#{original_organization.name}' at #{Time.now}"
      original_organization.copy_number = new_copy_number
    })
  end

end


