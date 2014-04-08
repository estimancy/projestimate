#########################################################################
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
########################################################################

class UnitOfWork < ActiveRecord::Base
  attr_accessible :alias, :description, :name, :organization_id, :organization_technology_ids, :state

  include AASM

  aasm :column => :state do # defaults to aasm_state
    state :draft, :initial => true
    state :defined
    state :retired
  end

  belongs_to :organization
  has_and_belongs_to_many :organization_technologies

  has_many :organization_uow_complexities, :through => :abacus_organizations
  has_many :abacus_organizations, :dependent => :destroy

  has_many :organization_uow_complexities, :dependent => :destroy

  validates :name, :alias, :presence => true

  default_scope order('alias ASC')

end
