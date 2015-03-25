class ViewsWidget < ActiveRecord::Base
  attr_accessible :color, :icon_class, :module_project_id, :name, :pbs_project_element_id, :estimation_value_id, :pe_attribute_id, :show_min_max, :view_id, :widget_id, :position, :position_x, :position_y, :width, :height, :widget_type, :show_name, :show_wbs_activity_ratio

  belongs_to :view
  belongs_to :widget
  belongs_to :estimation_value
  belongs_to :pe_attribute
  belongs_to :pbs_project_element
  belongs_to :module_project

  has_many :project_fields

  validates :name, :module_project_id, :estimation_value_id, presence: true

  amoeba do
    enable
    include_association [:project_fields]
  end

  def to_s
    name
  end

end

