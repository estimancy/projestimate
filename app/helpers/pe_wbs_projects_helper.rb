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
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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

module PeWbsProjectsHelper
  #Generate an powerful Work Breakdown Structure

  ##========================================== FOR WBS PRODUCT ======================================================##

  def generate_wbs_product(pbs_project_element, project, tree, gap, is_project_show_view = false)

    all_pbs_project_element = pbs_project_element.children.sort_by(&:position)

    #Root is always display
    if !pbs_project_element.nil? && pbs_project_element.is_root?
      tree << "<ul>
         #{wbs_root_links(pbs_project_element, is_project_show_view)}"
    end

    if pbs_project_element.has_children?
      gap = gap + 2
      tree << "<ul class='sortable' style='margin-left:#{gap}px; border-left: 1px solid black; padding-left: 8px;''>"
      all_pbs_project_element.each do |c|
        if c.work_element_type.alias == "folder"
          tree << wbs_folder_links(c, is_project_show_view)
        else
          tree << wbs_navigation_links(c, is_project_show_view)
        end
        generate_wbs_product(c, project, tree, gap)
      end
      tree << "</ul>"
    else
      #Nothing
    end

    return tree
  end

  def wbs_navigation_links(pbs_project_element, is_project_show_view)
    "<li>
        <div class='block_label #{ pbs_project_element == current_component ? "selected_pbs" : '' } change_component_graph'>
          <a href=#{ selected_pbs_project_element_path(:pbs_id => pbs_project_element.id, project_id: @project.id, :is_project_show_view => is_project_show_view) } data-remote=true>
            <i class='icon-file'></i>
            #{ content_tag('i', '', :class => "#{ pbs_project_element.is_completed ? 'icon-star' : 'icon-star-empty' } ") }
            #{ content_tag('i', '', :class => "#{ pbs_project_element.is_validated ? 'icon-circle' : 'icon-circle-blank' } ") }
            #{pbs_project_element.link? ? (pbs_project_element.project_link.nil? ? '!! undefined link' : Project.find(pbs_project_element.project_link)) : pbs_project_element.name}
          </a>
        </div>
        <div class='block_link'>
          #{ link_to "", edit_pbs_project_element_path(pbs_project_element, :project_id => @project.id), :remote => true, :class => 'button_attribute_tooltip icon-edit ', :title => I18n.t('edit') unless is_project_show_view }
          #{ link_to "", pbs_project_element, confirm: I18n.t('are_you_sure'), method: :delete, :remote => true, :class => 'button_attribute_tooltip icon-trash ', :title => I18n.t('delete') unless is_project_show_view }
          #{ link_to "", up_path(:pbs_project_element_id => pbs_project_element.id, :pe_wbs_project_id => pbs_project_element.pe_wbs_project_id, :project_id => @project.id), :remote => true, :class => 'button_attribute_tooltip icon-arrow-up ', :title => I18n.t('up') unless is_project_show_view }
          #{ link_to "", down_path(:pbs_project_element_id => pbs_project_element.id, :pe_wbs_project_id => pbs_project_element.pe_wbs_project_id, :project_id => @project.id), :remote => true, :class => 'button_attribute_tooltip icon-arrow-down ', :title => I18n.t('down')  unless is_project_show_view }
        </div>
      </li>"
  end

  def wbs_folder_links(pbs_project_element, is_project_show_view)
    "<li>
        <div class='block_label #{ pbs_project_element == current_component ? 'selected_pbs' : '' }'>
          <div>
              <a href=#{ selected_pbs_project_element_path(:pbs_id => pbs_project_element.id, :is_project_show_view => is_project_show_view, project_id: @project.id) } data-remote=true>
                <i class='icon-folder-open'></i>
                #{ content_tag('i', '', :class => "#{ pbs_project_element.is_completed ? 'icon-star' : 'icon-star-empty' } ") }
                #{ content_tag('i', '', :class => "#{ pbs_project_element.is_validated ? 'icon-circle' : 'icon-circle-blank' } ") }
                #{pbs_project_element.name}
              </a>
          </div>
        </div>
        <div class='block_link'>
          #{ link_to "", edit_pbs_project_element_path(pbs_project_element, :project_id => @project.id), :remote => true, :class => 'button_attribute_tooltip icon-edit ', :title => I18n.t('edit') unless is_project_show_view }
          #{ link_to "", new_pbs_project_element_path(:project_id => @project.id, :parent_id => pbs_project_element.id), :remote => true, :class => 'button_attribute_tooltip icon-folder-open ', :title => I18n.t('add_folder') unless is_project_show_view }
          #{ link_to "", new_pbs_project_element_path(:project_id => @project.id, :parent_id => pbs_project_element.id), :remote => true, :class => 'button_attribute_tooltip icon-plus ', :title => I18n.t('add_component') unless is_project_show_view }
          #{ link_to "", new_pbs_project_element_path(:project_id => @project.id, :parent_id => pbs_project_element.id), :remote => true, :class => 'button_attribute_tooltip icon-link ', :title => I18n.t('add_link') unless is_project_show_view }
          #{ link_to "", pbs_project_element, confirm: I18n.t('are_you_sure'), method: :delete, :remote => true, :class => 'button_attribute_tooltip icon-trash', :title => I18n.t('delete')}
          #{ link_to "", {:controller => 'pbs_project_elements', :action => 'up', :pbs_project_element_id => pbs_project_element.id, :pe_wbs_project_id => pbs_project_element.pe_wbs_project_id, :project_id => @project.id}, :remote => true, :class => 'button_attribute_tooltip icon-arrow-up ', :title => I18n.t('up') unless is_project_show_view }
          #{ link_to "", {:controller => 'pbs_project_elements', :action => 'down', :pbs_project_element_id => pbs_project_element.id, :pe_wbs_project_id => pbs_project_element.pe_wbs_project_id, :project_id => @project.id}, :remote => true, :class => 'button_attribute_tooltip icon-arrow-down ', :title => I18n.t('down') unless is_project_show_view }
        </div>
    </li>"
  end

  def wbs_root_links(pbs_project_element, is_project_show_view)
    "<li class=''>
        <div class='block_label #{ pbs_project_element == current_component ? 'selected_pbs' : '' }'>
          <div class='change_component_graph'>
            <a href=#{selected_pbs_project_element_path(:pbs_id => pbs_project_element.id, :project_id => @project.id)} data-remote=true>
              <i class='icon-folder-open'></i>
              #{ content_tag('i', '', :class => "#{ pbs_project_element.is_completed ? 'icon-star' : 'icon-star-empty' } ") }
              #{ content_tag('i', '', :class => "#{ pbs_project_element.is_validated ? 'icon-circle' : 'icon-circle-blank' } ") }
              #{pbs_project_element.name}
            </a>
          </div>
        </div>
        <div class='block_link'>
          #{ link_to "", edit_pbs_project_element_path(pbs_project_element, :project_id => @project.id), :remote => true, :class => 'button_attribute_tooltip icon-edit ', :title => I18n.t('edit') unless is_project_show_view }
          #{ link_to("", new_pbs_project_element_path(:project_id => @project.id, :work_element_type => "folder", :parent_id => pbs_project_element.id), :remote => true, :class => 'button_attribute_tooltip icon-folder-open ', :title => I18n.t('add_folder')) unless is_project_show_view }
          #{ link_to "", new_pbs_project_element_path(:project_id => @project.id, :work_element_type => "component", :parent_id => pbs_project_element.id), :remote => true, :class => 'button_attribute_tooltip icon-plus ', :title => I18n.t('add_component') unless is_project_show_view }
          #{ link_to "", new_pbs_project_element_path(:project_id => @project.id, :work_element_type => "link", :parent_id => pbs_project_element.id), :remote => true, :class => 'button_attribute_tooltip icon-link ', :title => I18n.t('add_link') unless is_project_show_view }
        </div>
      </li>"
  end
end

#J'ai supprimer provisoirement
#onClick='toggle_folder(this);'



