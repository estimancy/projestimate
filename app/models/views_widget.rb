class ViewsWidget < ActiveRecord::Base
  attr_accessible :color, :icon_class, :module_project_id, :name, :pbs_project_element_id, :pe_attribute_id, :show_min_max, :view_id, :widget_id, :position_x, :position_y, :width, :height, :widget_type, :show_name

  belongs_to :view
  belongs_to :widget
  belongs_to :pe_attribute
  belongs_to :pbs_project_element
  belongs_to :module_project

  has_many :project_field

  validates :name, :pe_attribute_id, :pbs_project_element_id, :module_project_id, :widget_type,  presence: true

end


#module_project_id:integer pe_attribute_id:integer pbs_project_element_id:integer view_id:integer widget_id:integer color:string icon_class:string name:string show_min_max:boolean