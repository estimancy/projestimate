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

module WbsActivityElementsHelper

  #Generate tree of Activity Element (wbs_activities/:id/edit)
  def generate_activity_element_tree(element, tree)
    #Root is always display
    tree ||= String.new
    unless element.nil?
      if element.is_root?
        tree << "<ul style='margin-left:1px;' id='tree'>
                   <li style='margin-left:-1px;'>
                    <div class='block_label'>
                        #{show_element_name(element)}
                    </div>
                    <div class='block_link'>
                      #{ link_activity_element(element) }
                    </div>
                  </li>"
      end

      if element.has_children?
        tree << "<ul class='sortable'>"
        element.children.each do |e|
          tree << "
                   <li style='margin-left:#{element.depth}px;' >
                    <div class='block_label'>
                      #{show_element_name(e)}
                    </div>
                    <div class='block_link'>
                      #{ link_activity_element(e) }
                    </div>
                  </li>"

          generate_activity_element_tree(e, tree)
        end
        tree << '</ul>'
      end
    end
    tree
  end


  #Generate tree of Activity Element (projects/:id/edit and dashboard)
  def generate_wbs_project_elt_tree(element, tree, show_hidden=false, is_project_show_view=false)
    #Root is always display
    gap = 2.5
    tree ||= String.new
    unless element.nil?
      if element.is_root?
        tree << "<ul style='margin-left:1px;' id='tree'>
                   <li style='margin-left:-1px;'>
                    <div class='block_label'>
                        #{ show_element_name(element) }
                    </div>
                    <div class='block_link'>
                      #{ link_activity_element(element, is_project_show_view) }
                    </div>
                  </li>"
      end

      if element.has_children?
        tree << "<ul class='sortable'>"
        element.children.each do |e|
          if show_hidden == 'true'
            tree << "
                     <li style='margin-left:-#{gap+element.depth}px;' >
                      <div class='block_label'>
                        #{show_element_name(e)}
                      </div>
                      <div class='block_link'>
                        #{ link_activity_element(e, is_project_show_view) }
                      </div>
                    </li>"

            generate_wbs_project_elt_tree(e, tree, show_hidden, is_project_show_view)
          else
            unless e.exclude
              tree << "
                       <li style='margin-left:-#{gap+element.depth}px;' >
                        <div class='block_label'>
                          #{show_element_name(e)}
                        </div>
                        <div class='block_link'>
                          #{ link_activity_element(e, is_project_show_view) }
                        </div>
                      </li>"

              generate_wbs_project_elt_tree(e, tree, show_hidden, is_project_show_view)
            end
          end
        end
        tree << '</ul>'
      end
    end
    tree
  end


  def show_element_name(element)
    if element.attributes.has_key? 'record_status_id'
      if element.is_root?
        "<span class='#{h element.record_status.to_s }'>#{h element.name} </span>"
      else
        "<span class='#{h element.record_status.to_s }'> #{h element.name} </span>"
      end

    else
      if element.is_root?
        #"<span class=''>#{element.pe_wbs_project.name} WBS-Activity</span>"
        "<span class=''>#{h @project.title} WBS-Activity </span>"
      else
        if element.wbs_activity_element.nil? && element.wbs_activity.nil?
          "<span class=''> * #{h element.name} </span>"
        else
          "<span class=''> #{h element.name} </span>"
        end
      end
    end
  end


  def link_activity_element(element, is_project_show_view=false)
    if can? :edit_wbs_activities, WbsActivity
      res = String.new
      unless is_project_show_view
        if element.attributes.has_key? 'record_status_id'
          res << link_to('', new_wbs_activity_element_path(:selected_parent_id => element.id, :activity_id => element.wbs_activity_id), :class => 'button_attribute_tooltip icon-plus icon-large pull-left', :title => I18n.t('button_add'))
          res << link_to('', edit_wbs_activity_element_path(element, :activity_id => element.wbs_activity_id), :class => 'button_attribute_tooltip icon-edit icon-large pull-left', :title => I18n.t('edit'), :confirm => (I18n.t(:text_master_force_edit) if element.is_defined?))
          res << link_to('', element, confirm: I18n.t('are_you_sur'), method: :delete, :class => 'button_attribute_tooltip icon-trash icon-large pull-left', :title => I18n.t('delete'))

          unless enable_update_in_local?
            res = link_to('', wbs_activity_element_path(element, :activity_id => element.wbs_activity_id), method: :get, :class => 'icon-eye-open icon-large', :title => 'Show', :remote => true)
          end

        else
          res << link_to_unless(element.cannot_get_new_child_link?, '', new_wbs_project_element_path(:selected_parent_id => element.id, :project_id => @project.id), :class => 'button_attribute_tooltip icon-plus icon-large pull-left', :title => I18n.t('button_add'))
          res << link_to_unless(element.is_root?, '', edit_wbs_project_element_path(element, :project_id => @project.id), :class => 'button_attribute_tooltip icon-edit icon-large pull-left', :title => I18n.t('edit'))
          res << link_to_unless(element.is_root?, '', wbs_project_element_path(element, :project_id => @project.id), confirm: I18n.t('are_you_sur'), method: :delete, :project_id => @project.id, :class => 'button_attribute_tooltip icon-trash icon-large pull-left', :title => I18n.t('delete')) unless  !element.destroy_leaf
          res << link_to_if(element.is_added_wbs_root, '', "wbs_project_elements/#{element.id}/change_wbs_project_ratio", :wbs_project_element_id => element.id, :project_id => @project.id, :class => 'button_attribute_tooltip icon-share icon-large pull-left', :title => I18n.t('change_ratio'), :remote => true)
        end
      end
      res
    end
  end

end
