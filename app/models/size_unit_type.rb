class SizeUnitType < ActiveRecord::Base

  validates :name, :presence => true

  attr_accessible :description, :name, :alias, :organization_id#, :record_status_id, :custom_value, :change_comment

  belongs_to :organization

  has_many :technology_size_types
  has_many :organization_technologies, through: :technology_size_types

  has_many :size_units
end
