class View < ActiveRecord::Base
  attr_accessible :name, :description, :organization_id, :pemodule_id, :is_default_view, :is_reference_view, :initial_view_id

  belongs_to :organization
  belongs_to :pemodule

  has_many :module_projects, dependent: :nullify
  has_many :views_widgets, dependent: :destroy
  has_many :widgets, through: :views_widgets

  validates :name, :organization_id, presence: true

  def to_s
    name
  end
end
