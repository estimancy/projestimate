class Application < ActiveRecord::Base
  attr_accessible :name, :organization_id
  belongs_to :organization

  has_and_belongs_to_many :projects
end
