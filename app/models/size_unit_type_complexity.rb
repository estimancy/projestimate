class SizeUnitTypeComplexity < ActiveRecord::Base
  attr_accessible :organization_uow_complexity_id, :size_unit_type_id, :value
  belongs_to :size_unit_type
end
