class Widget < ActiveRecord::Base
  attr_accessible :color, :icon_class, :name, :pe_attribute_id

  belongs_to :pe_attribute

  has_many :views_widgets, dependent: :nullify
  has_many :views, through: :views_widgets

  validates :name, presence: true

  def to_s
    name
  end

end
