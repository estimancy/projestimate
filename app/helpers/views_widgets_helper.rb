#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

module ViewsWidgetsHelper

  # Get the view_widget data for each view/widget/module_project
  def get_view_widget_data(module_project_id, view_widget_id)

    view_widget = ViewsWidget.find(view_widget_id)
    pbs_project_elt = current_component
    module_project = ModuleProject.find(module_project_id)
    estimation_value = module_project.estimation_values.where('pe_attribute_id = ? AND in_out = ?', view_widget.pe_attribute_id, "output").last
    widget_data = {}
    data_probable = ""; min_value = ""; max_value = ""; value_to_show = ""
    width = 150;  height = 150
    value_to_show = "" # according to the widget type

    unless estimation_value.nil?
      data_low = estimation_value.string_data_low[pbs_project_elt.id]
      data_high = estimation_value.string_data_high[pbs_project_elt.id]
      data_most_likely = estimation_value.string_data_most_likely[pbs_project_elt.id]
      data_probable = estimation_value.string_data_probable[pbs_project_elt.id]
      probable_value_text =  display_value(data_probable, estimation_value)
      max_value_text = "Max: #{data_high.nil? ? '-' : data_high.round(user_number_precision)}"
      min_value_text = "Min: #{data_low.nil? ? '-' : data_low.round(user_number_precision)}"
    end
    widget_data = { data_low: data_low, data_high: data_high, data_most_likely: data_most_likely, data_probable: data_probable, max_value_text: max_value_text, min_value_text: min_value_text, probable_value_text: probable_value_text }

    # The widget size with : margin-right = 10px
    if view_widget.width.to_i > 1
      width = (150*view_widget.width.to_i) + 10*(view_widget.width.to_i - 1)
    end
    if view_widget.height.to_i > 1
      height = (150*view_widget.height.to_i) + 10*(view_widget.height.to_i - 1)
    end
    widget_data[:width] = width
    widget_data[:height] = height

    add_top_and_left = nil
    if  !view_widget.position_x.nil? && !view_widget.position_y.nil?
      add_top_and_left = "left: #{view_widget.position_x} ; top: #{view_widget.position_y}";
    end

    #WIDGETS_TYPE = [["Simple text", "text"], ["Line chart", "line_chart"], ["Bar chart", "bar_chart"], ["Area chart", "area_chart"], ["Pie chart","pie_chart"], ["Timeline", "timeline"], ["Stacked bar chart", "stacked_bar_chart"] ]
    #According to the widget type, we will show simple text, charts, timeline, etc
    chart_level_values = []
    ["low", "most_likely", "high", "probable"].each do |level|
      chart_level_values << [level, "data_#{level}"]
    end

    case view_widget.widget_type
      when "text"
        value_to_show = probable_value_text

      when "line_chart"
        value_to_show = line_chart(chart_level_values)

      when "bar_chart"

      when "area_chart"

      when "pie_chart"
        value_to_show = pie_chart(chart_level_values)

      when "stacked_bar_chart"

      when "timeline"
      else
        value_to_show = probable_value_text
    end

    view_widget[:value_to_show] = value_to_show

    # Return the view_widget HASH
    widget_data
  end

end
