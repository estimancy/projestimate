class View < ActiveRecord::Base
  attr_accessible :name, :description, :organization_id

  belongs_to :organization

  has_many :module_projects
  has_many :views_widgets, dependent: :destroy
  has_many :widgets, through: :views_widgets

  validates :name, presence: true

  def to_s
    name
  end
end
