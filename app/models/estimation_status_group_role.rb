class EstimationStatusGroupRole < ActiveRecord::Base
  attr_accessible :estimation_status_id, :group_id, :permission_id, :organization_id

  belongs_to :group
  belongs_to :estimation_status
  belongs_to :permission
  belongs_to :organization

  validates :group_id, :estimation_status_id, :permission_id, :organization_id, presence: true
end
