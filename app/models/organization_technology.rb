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

class OrganizationTechnology < ActiveRecord::Base
  attr_accessible :alias, :description, :name, :organization_id, :productivity_ratio, :state, :unit_of_work_ids

  include AASM

  aasm :column => :state do # defaults to aasm_state
    state :draft, :initial => true
    state :defined
    state :retired
  end

  belongs_to :organization
  has_many :pbs_project_elements
  has_and_belongs_to_many :unit_of_works
  has_many :inputs, :foreign_key => :technology_id
  has_many :organization_uow_complexities

  validates :name, :alias, :presence => true, :uniqueness => {:scope => :organization_id, :case_sensitive => false}

  default_scope { order('alias DESC') }

  def to_s
    name || ''
  end

  # To definitively remove
  # Add the amoeba gem for the copy
  #amoeba do
  #  enable
  #  include_field [:unit_of_works, :abacus_organizations, :organization_uow_complexities]
  #  #exclude_field [:pbs_project_elements, :inputs]
  #  #propagate
  #end
end
