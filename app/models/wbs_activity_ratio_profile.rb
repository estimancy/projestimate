class WbsActivityRatioProfile < ActiveRecord::Base
  attr_accessible :organization_profile_id, :ratio_value, :wbs_activity_ratio_element_id

  belongs_to :wbs_activity_ratio_element
  belongs_to :organization_profile

  validates :wbs_activity_ratio_element_id, :organization_profile_id, :presence => true
  validates :ratio_value, :numericality => { :allow_blank => true }
end
