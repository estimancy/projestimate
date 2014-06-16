class TechnologySizeType < ActiveRecord::Base
  attr_accessible :organization_id, :organization_technology_id, :size_unit_id, :size_unit_type_id, :value

  belongs_to :organization
  belongs_to :organization_technology
  belongs_to :size_unit
  belongs_to :size_unit_type

end
