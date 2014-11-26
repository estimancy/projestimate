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
    project = module_project.project
    estimation_value = module_project.estimation_values.where('pe_attribute_id = ? AND in_out = ?', view_widget.pe_attribute_id, "output").last
    widget_data = {}
    data_probable = ""; min_value = ""; max_value = ""; value_to_show = ""
    width = 60;  height = 60
    value_to_show = nil # according to the widget type
    data_low = nil; data_most_likely=nil; data_high=nil; data_probable=nil

    unless estimation_value.nil?
      data_low = estimation_value.string_data_low[pbs_project_elt.id]
      data_high = estimation_value.string_data_high[pbs_project_elt.id]
      data_most_likely = estimation_value.string_data_most_likely[pbs_project_elt.id]
      data_probable = estimation_value.string_data_probable[pbs_project_elt.id]
      probable_value_text =  display_value(data_probable, estimation_value)
      max_value_text = "Max: #{data_high.nil? ? '-' : display_value(data_high, estimation_value, false)}" #max_value_text = "Max: #{data_high.nil? ? '-' : data_high.round(user_number_precision)}"
      min_value_text = "Min: #{data_low.nil? ? '-' : display_value(data_low, estimation_value, false)}"   #min_value_text = "Min: #{data_low.nil? ? '-' : data_low.round(user_number_precision)}"
    end
    widget_data = { data_low: data_low, data_high: data_high, data_most_likely: data_most_likely, data_probable: data_probable, max_value_text: max_value_text, min_value_text: min_value_text, probable_value_text: probable_value_text }

    ft_maxFontSize_without_mm = 75
    ft_maxFontSize_with_mm = 60
    ft_minMax_maxFontSize = 20
    icon_font_size = 2

    # The widget size with : margin-right = 10px
    height = (height*view_widget.height.to_i) + 10*(view_widget.height.to_i - 1)
    width = (width*view_widget.width.to_i) + 10*(view_widget.width.to_i - 1)

    case view_widget.height.to_i
      when 1..2
        icon_font_size = 2
        if view_widget.height.to_i == 3
          icon_font_size = 3
        end
        ft_maxFontSize_without_mm = 30
        ft_maxFontSize_with_mm = 30
        ft_minMax_minFontSize = 6
        ft_minMax_maxFontSize = 12

        if view_widget.width.to_i <= 1
          ft_minMax_minFontSize = 4.5
        else
          ft_minMax_minFontSize = 7.5
        end

      when 3
        icon_font_size = 3
        ft_maxFontSize_without_mm = 30
        ft_maxFontSize_with_mm = 30
        ft_minMax_maxFontSize = 12
      else
        height = (height*view_widget.height.to_i) + 10*(view_widget.height.to_i - 1)
        icon_font_size = ((height+width)/2) * 0.025
        if icon_font_size > 6 && icon_font_size < 8
          icon_font_size = 6
        elsif icon_font_size > 8
          icon_font_size = 8
        end
    end

    text_size = ((height+width)/2) * 0.015
    min_max_size = ((height+width)/2) * 0.009

    #if view_widget.height.to_i > 2
    #  height = (height*view_widget.height.to_i) + 10*(view_widget.height.to_i - 1)
    #  icon_font_size = ((height+width)/2) * 0.025
    #else
    #  icon_font_size = 2
    #  ft_maxFontSize_without_mm = 30
    #  ft_maxFontSize_with_mm = 30
    #  ft_minMax_maxFontSize = 15
    #
    #  if view_widget.width.to_i <= 1
    #    ft_minMax_minFontSize = 4.5
    #  else
    #    ft_minMax_minFontSize = 7.5
    #  end
    #
    #end

    # get the fitText minFontSize and maxFontSize

    # update size in the results hash
    widget_data[:width] = width
    widget_data[:height] = height
    widget_data[:icon_font_size] = icon_font_size
    widget_data[:text_size] = text_size
    widget_data[:min_max_size] = min_max_size
    # fitText parameters
    widget_data[:ft_maxFontSize_without_mm] = ft_maxFontSize_without_mm
    widget_data[:ft_maxFontSize_with_mm] = ft_maxFontSize_with_mm
    widget_data[:ft_minMax_minFontSize] = ft_minMax_minFontSize
    widget_data[:ft_minMax_maxFontSize] = ft_minMax_maxFontSize

    #WIDGETS_TYPE = [["Simple text", "text"], ["Line chart", "line_chart"], ["Bar chart", "bar_chart"], ["Area chart", "area_chart"], ["Pie chart","pie_chart"], ["Timeline", "timeline"], ["Stacked bar chart", "stacked_bar_chart"] ]
    #According to the widget type, we will show simple text, charts, timeline, etc
    chart_level_values = []
    chart_level_values << ["low", data_low]
    chart_level_values << ["ml", data_most_likely]
    chart_level_values << ["high", data_high]
    chart_level_values << ["probable", data_probable]

    widget_data[:chart_level_values] = chart_level_values
    chart_height = height-50
    chart_width = width -50
    chart_title = view_widget.name
    chart_vAxis = view_widget.pe_attribute.name
    chart_hAxis = "Level"

    case view_widget.widget_type
      when "text"
        value_to_show = probable_value_text

      when "line_chart"
        #value_to_show = line_chart(chart_level_values, height: "#{chart_height}px", library: {backgroundColor: view_widget.color})
        value_to_show =  line_chart([
            {name: "Low", data: {Time.new => data_low} },  #10
            {name: "Most likely", data: {Time.new => data_most_likely} }, #30
            {name: "High", data: {Time.new => data_high} } ],  #50
            {height: "#{chart_height}px", library: {title: chart_title, hAxis: {title: "Level", format: 'MMM y'}, vAxis: {title: view_widget.pe_attribute.name}}})

      when "bar_chart"
        value_to_show = column_chart(chart_level_values, height: "#{chart_height}px", library: {title: chart_title, vAxis: {title: chart_vAxis}})

      when "area_chart"
        value_to_show = area_chart(chart_level_values, height: "#{chart_height}px", library: {title: view_widget.name, vAxis: {title: view_widget.chart_vAxis}})

      when "pie_chart"
        value_to_show = pie_chart(chart_level_values, height: "#{chart_height}px", library: {title: chart_title})

      when "stacked_bar_chart"
        value_to_show = probable_value_text

      when "timeline"
        timeline_data = []
        delay = PeAttribute.where(alias: "delay").first
        end_date = PeAttribute.where(alias: "end_date").first
        staffing = PeAttribute.where(alias: "staffing").first
        effort = PeAttribute.where(alias: "effort").first

        # Get the component/PBS children
        products = pbs_project_elt.subtree.sort_by(&:position)
        products.each_with_index do |element, i|
          begin
            dev = dev = module_project.estimation_values.where(pe_attribute_id: delay.id).first.string_data_probable[element.id]
            if !dev.nil?
              d = dev.to_f
              if d.nil?
                dh = 1.hours
              else
                dh = d.hours
              end
              ed = module_project.estimation_values.where(pe_attribute_id: end_date.id).first.string_data_probable[element.id]

              #pbs_project_elt.end_date = ed
              #pbs_project_elt.save

              unless dh.nan?
                timeline_data << [element.name, element.start_date.nil? ? project.start_date : element.start_date, element.start_date.nil? ? project.start_date + dh : element.start_date + dh]
              else
                timeline_data << [element.name, element.start_date.nil? ? project.start_date : element.start_date, element.start_date.nil? ? project.start_date : element.start_date]
              end
            end
          rescue

          end
        end

        #value_to_show = timeline([["Washington", "1789-04-29", "1797-03-03"], ["Adams", "1797-03-03", "1801-03-03"], ["Jefferson", "1801-03-03", "1809-03-03"]], height: "#{chart_height}px")
        value_to_show = timeline(timeline_data, library: {title: view_widget.pe_attribute.name})

      else
        value_to_show = probable_value_text
    end

    widget_data[:value_to_show] = value_to_show

    # Return the view_widget HASH
    widget_data
  end

end
