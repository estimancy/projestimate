class Field < ActiveRecord::Base
  attr_accessible :name, :organization_id
  belongs_to :organization
  belongs_to :project_field

  #Search fields
  scoped_search :on => [:name]
end
