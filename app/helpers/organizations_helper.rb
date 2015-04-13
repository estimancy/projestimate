#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2015 Estimancy (http://www.estimancy.com)
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

module OrganizationsHelper

  def update_selected_inline_columns(query)
    selected_columns = []
    #selected_columns = query.available_inline_columns.select{ |column| column.name.to_s.in?(@current_organization.project_selected_columns)}
    #selected_columns = query.available_inline_columns.select{ |column| column.name.to_s.in?(@current_organization.project_selected_columns)}
    @current_organization.project_selected_columns.each do |column_name|
      selected_columns << query.available_inline_columns.select{ |column| column.name.to_s == column_name}
    end
    selected_columns.flatten
  end

  def query_available_inline_columns_options(query)
    selected_inline_columns = update_selected_inline_columns(query)
    (query.available_inline_columns - selected_inline_columns).collect {|column| [column.caption, column.name]}
  end

  def query_selected_inline_columns_options(query)
    selected_inline_columns = update_selected_inline_columns(query)
    selected_inline_columns.collect {|column| [ column.caption, column.name]}
  end

  def column_header(column)
    #content_tag('th', h(column.caption))
    case column.name
      when :product_name, :title
        content_tag('th class="text_left exportable"', h(column.caption))
      when :version
        content_tag('th class="center exportable"', h(column.caption))
      when :status_name
        content_tag('th style="width: 50px" class="filter-select exportable"', h(column.caption))
      else
        content_tag('th class="exportable"', h(column.caption))
    end
  end

  def column_content(column, project)
    value = column.value_object(project)
    if value.is_a?(Array)
      value.collect {|v| column_value(column, project, v)}.compact.join(', ').html_safe
    else
      column_value(column, project, value)
    end
  end

  def column_value(column, project, value)
    case column.name
      when :product_name
        content_tag('td class="text_field_text_overflow exportable"', project.root_component)
      when :title
        content_tag('td class="exportable"', can_show_estimation?(project) ? link_to(value, dashboard_path(project), :class => 'button_attribute_tooltip pull-left') : value)
      when :version
        content_tag('td class="center exportable"', value)
      when :status_name
        if can_show_estimation?(project)
          #content_tag 'td class="exportable"', content_tag(:span, link_to(project.status_name, main_app.add_comment_on_status_change_path(:project_id => project.id), style: "color: #FFFFFF;", :title => "#{I18n.t(:label_add_status_change_comment)}" , :remote => true),
                                       #class: "badge", style: {"background-color" => project.status_background_color})
          content_tag(:td, class: "exportable") do
            content_tag(:span, link_to(project.status_name, main_app.add_comment_on_status_change_path(:project_id => project.id), style: "color: #FFFFFF;", :title => "#{I18n.t(:label_add_status_change_comment)}" , :remote => true),
                        class: "badge", style: "background-color: #{project.status_background_color}").html_safe
          end
        else
          #content_tag('td class="exportable"', content_tag('span class="badge" style="background-color: #{project.status_background_color}', project.status_name))
          content_tag(:td, class: "exportable") do
            content_tag(:span, project.status_name, class: "badge", style: "background-color: #{project.status_background_color}").html_safe
          end
        end
      when :description
        content_tag('td', value, :class => "text_field_text_overflow exportable")
      when :start_date, :created_at, :updated_at
        content_tag('td class="center exportable"', I18n.l(value))
      else
        content_tag('td class="text_field_text_overflow exportable"', value)
    end
  end

end
