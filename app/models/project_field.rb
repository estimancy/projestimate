class ProjectField < ActiveRecord::Base
  attr_accessible :field_id, :project_id, :views_widget_id, :value
  belongs_to :field

  #Search fields
  scoped_search :in => :field, :on => :name
end
