#encoding: utf-8

class WbsActivityInput < ActiveRecord::Base
  attr_accessible :wbs_activity_id, :wbs_activity_ratio_id, :module_project_id, :pbs_project_element_id, :comment

  belongs_to :wbs_activity
  belongs_to :wbs_activity_ratio
  belongs_to :module_project
  belongs_to :pbs_project_element
end
