class Field < ActiveRecord::Base
  attr_accessible :name, :organization_id, :coefficient

  belongs_to :organization
  belongs_to :project_field

  validates_presence_of :coefficient

  #Search fields
  scoped_search :on => [:name]

  amoeba do
    enable
    customize(lambda { |original_field, new_field|
      new_field.copy_id = original_field.id
    })
  end
end
