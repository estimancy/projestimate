class InputCocomo < ActiveRecord::Base
  belongs_to :factor
  belongs_to :organization_uow_complexity
  belongs_to :project
  belongs_to :module_project
end
