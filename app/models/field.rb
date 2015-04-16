class Field < ActiveRecord::Base
  attr_accessible :name, :organization_id, :coefficient
  belongs_to :organization
  belongs_to :project_field

  validates_presence_of :coefficient

  #Search fields
  scoped_search :on => [:name]
end
