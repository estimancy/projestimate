class ProjectField < ActiveRecord::Base
  attr_accessible :field_id, :project_id, :views_widget_id, :value
end
