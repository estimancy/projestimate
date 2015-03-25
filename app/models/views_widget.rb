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

  def self.update_field(view_widget, field_id, project, component)
    pf = ProjectField.where(field_id: field_id, project_id: project.id, views_widget_id: view_widget.id).first

    @value = 0

    if view_widget.estimation_value.module_project.pemodule.alias == "effort_breakdown"
      begin
        @value = view_widget.estimation_value.string_data_probable[component.id][view_widget.estimation_value.module_project.wbs_activity.wbs_activity_elements.first.root.id][:value]
      rescue
        begin
          @value = view_widget.estimation_value.string_data_probable[project.root_component.id]
        rescue
          @value = 0
        end
      end
    else
      @value = view_widget.estimation_value.string_data_probable[component.id]
    end

    if pf.nil?
      ProjectField.create(project_id: project.id,
                          field_id: field_id,
                          views_widget_id: view_widget.id,
                          value: @value)
    else
      pf.value = @value
      pf.views_widget_id = view_widget.id
      pf.field_id = field_id
      pf.project_id = project.id
      pf.save
    end
  end


end