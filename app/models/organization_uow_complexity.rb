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


class OrganizationUowComplexity < ActiveRecord::Base
  include MasterDataHelper

  attr_accessible :name, :description, :display_order, :state, :factor_id, :unit_of_work_id, :value, :record_status_id, :organization_id, :organization_technology_id

  include AASM
  aasm :column => :state do # defaults to aasm_state
    state :draft, :initial => true
    state :defined
    state :retired
  end

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'
  belongs_to :organization

  has_many :size_unit_type_complexities, :dependent => :destroy

  belongs_to :factor
  belongs_to :unit_of_work
  belongs_to :organization_technology
  belongs_to :size_unit_type

  #default_scope order('display_order ASC')

  validates :record_status, :presence => true
  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name, :presence => true
  validates :custom_value, :presence => true, :if => :is_custom?

  #validates_presence_of :unit_of_work_id
  #validates_presence_of :organization_technology_id

  #Search fields
  scoped_search :on => [:name, :description]
  scoped_search :in => :organization, :on => :name


  amoeba do
    enable
    exclude_association [:users, :organization_uow_complexities]

    customize(lambda { |original_record, new_record|
      new_record.reference_uuid = original_record.uuid
      new_record.reference_id = original_record.id
      new_record.record_status = RecordStatus.find_by_name('Proposed')
    })
  end

  def to_s
    self.nil? ? '' : self.name
  end

end
