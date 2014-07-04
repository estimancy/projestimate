class ActivityProfile < ActiveRecord::Base
  attr_accessible :project_id, :wbs_project_element_id, :organization_profile_id, :ratio_percentage

  belongs_to :wbs_project_element
  belongs_to :organization_profile

  validates :ratio_percentage, :numericality => { :allow_blank => true }
end