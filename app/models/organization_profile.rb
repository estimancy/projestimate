class OrganizationProfile < ActiveRecord::Base
  attr_accessible :cost_per_hour, :description, :name, :organization_id

  belongs_to :organization

  has_many :wbs_activity_ratio_profiles

  validates :organization_id, :presence => true
  validates :name, :presence => true, :uniqueness => true
  validates :cost_per_hour, :numericality => { :allow_blank => true }
end
