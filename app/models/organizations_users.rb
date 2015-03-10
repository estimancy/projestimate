class OrganizationsUsers < ActiveRecord::Base
  attr_accessible :organization_id, :user_id

  belongs_to :organization
  belongs_to :user
end
