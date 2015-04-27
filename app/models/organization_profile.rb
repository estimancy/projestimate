class OrganizationProfile < ActiveRecord::Base
  attr_accessible :cost_per_hour, :description, :name, :organization_id, :profile_id

  belongs_to :organization

  has_many :wbs_activity_ratio_profiles, :dependent => :delete_all

  #validates :organization_id, :presence => true
  validates_uniqueness_of :name, :scope => :organization_id
  validates :cost_per_hour, :numericality => { :allow_blank => true }

  # Add the amoeba gem for the copy
  amoeba do
    enable
    exclude_association [:wbs_activity_ratio_profiles]
    customize(lambda { |original_organization_profile, new_organization_profile|
      new_organization_profile.copy_id = original_organization_profile.id
    })
  end

  #Search fields
  scoped_search :on => [:name, :description]
end
