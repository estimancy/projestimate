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
#    ===================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
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

class PbsProjectElementsController < ApplicationController

  #Create a new pbs_project_element and refresh the partials
  def new
    @project = Project.find(params[:project_id])
    authorize! :alter_wbsproducts, @project

    @pbs_project_element = PbsProjectElement.new
    set_page_title("New #{@pbs_project_element.name}")

    @project_wbs_activities = @project.organization.wbs_activities   # Select only Wbs-Activities affected to current project
    @pbs_wbs_activity_ratios = []

    if params[:work_element_type] == "folder"
      @work_element_type = WorkElementType.find_by_alias("folder")
    elsif params[:work_element_type] == "link"
      @work_element_type = WorkElementType.find_by_alias("link")
    else
      @work_element_type = WorkElementType.find_by_alias("undefined")
    end

    @parent = PbsProjectElement.find(params[:parent_id])

    @folder_components = @project.pe_wbs_projects.products_wbs.first.pbs_project_elements.select{ |i| i.work_element_type.alias == "folder" }

    unless @pbs_project_element.wbs_activity.nil?
      @pbs_wbs_activity_ratios = @pbs_project_element.wbs_activity.wbs_activity_ratios
    end
  end

  def edit
    @project = Project.find(params[:project_id])
    authorize! :alter_wbsproducts, @project

    @pbs_project_element = PbsProjectElement.find(params[:id])
    set_page_title("Editing #{@pbs_project_element.name}")

    @pe_wbs_project_activity = @project.pe_wbs_projects.activities_wbs.first
    @project_wbs_activities = @pe_wbs_project_activity.wbs_activities(:id).uniq   # Select only Wbs-Activities affected to current project
    @pbs_wbs_activity_ratios = []

    unless @pbs_project_element.wbs_activity.nil?
      @pbs_wbs_activity_ratios = @pbs_project_element.wbs_activity.wbs_activity_ratios
    end

    #Select folders which could be a parent of a pbs_project_element
    #a pbs_project_element cannot be its own parent
    @folder_components = @project.pe_wbs_projects.products_wbs.first.pbs_project_elements.select{ |i| i.work_element_type.alias == "folder" }
  end

  def create
    @project = Project.find(params[:project_id])
    authorize! :alter_wbsproducts, @project

    @pbs_project_element = PbsProjectElement.new(params[:pbs_project_element])
    @pbs_project_element.position = @pbs_project_element.siblings.length + 1
    @pbs_project_element.pe_wbs_project_id = @project.pe_wbs_projects.products_wbs.first.id
    @pbs_project_element.start_date = params[:pbs_project_element][:start_date]

    if @pbs_project_element.save
      if params[:pbs_project_element][:ancestry]
        @pbs_project_element.update_attribute :parent, PbsProjectElement.find(params[:pbs_project_element][:ancestry])
      else
        @pbs_project_element.update_attribute :parent, nil
      end
    else
      flash[:error] = I18n.t (:error_pbs_project_element_failed_update)
    end

    render :partial => "pbs_project_elements/refresh_tree"
  end

  def update
    @pbs_project_element = PbsProjectElement.find(params[:id])
    @project = @pbs_project_element.pe_wbs_project.project
    authorize! :alter_wbsproducts, @project

    if @pbs_project_element.update_attributes(params[:pbs_project_element])
      # Another update attributes...
      if params[:pbs_project_element][:ancestry]
        @pbs_project_element.update_attribute :parent, PbsProjectElement.find(params[:pbs_project_element][:ancestry])
      else
        @pbs_project_element.update_attribute :parent, nil
      end
    else
      flash[:error] = I18n.t (:error_pbs_project_element_failed_update)
    end

    render :partial => "pbs_project_elements/refresh_tree"
  end

  def destroy
    pbs_project_element = PbsProjectElement.find(params[:id])
    @project = pbs_project_element.pe_wbs_project.project

    authorize! :manage, @project

    @pbs_project_element = @project.root_component
    @module_projects = @project.module_projects


    elements_to_up = pbs_project_element.siblings.where("position > ?", pbs_project_element.position ).all

    #Destroy the selected pbs_project_element
    pbs_project_element.destroy

    elements_to_up.each do |element|
      element.position = element.position - 1
      element.save
    end

    render :partial => "pbs_project_elements/refresh_tree"
  end


  #Select the current pbs_project_element and refresh the partial
  def selected_pbs_project_element
    #No authorize required since everyone can select a PBS

    session[:pbs_project_element_id] = params[:pbs_id]

    @user = current_user
    @project = Project.find(params[:project_id])
    @is_project_view = params[:is_project_show_view]

    if @project.nil?
      @project = current_project
    end

    @module_projects = @project.module_projects
    @pbs_project_element = current_component

    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where("pemodule_id = ? AND project_id = ?", @initialization_module.id, @project.id).first  unless @initialization_module.nil?

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).sort_by{|i| i.position_y}.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    @results = nil
    render :partial => "pbs_project_elements/refresh"
  end


  #Pushed up the pbs_project_element
  def up
    @project = Project.find(params[:project_id])

    authorize! :alter_wbsproducts, @project

    component_a = PbsProjectElement.find(params[:pbs_project_element_id])
    component_b = component_a.siblings.all.select{|i| i.position == component_a.position - 1 }.first

    if (component_a.parent.id == component_a.root.id and component_a.position == 1) or component_a.siblings.size == 1
      puts "nothing"
    else
      component_a.update_attribute("position", component_a.position - 1)
      component_b.update_attribute("position", component_b.position + 1)
    end
    @user = current_user
    render :partial => "pbs_project_elements/refresh_tree"
  end

  #Pushed down the pbs_project_element
  def down
    @project = Project.find(params[:project_id])

    authorize! :alter_wbsproducts, @project

    component_a = PbsProjectElement.find(params[:pbs_project_element_id])
    component_b = component_a.siblings.all.select{|i| i.position == component_a.position + 1 }.first

    if component_b.nil? or component_a.siblings.size == 1
      puts "nothing"
    else
      component_a.update_attribute("position", component_a.position + 1)
      component_b.update_attribute("position", component_b.position - 1)
    end
    @user = current_user
    render :partial => "pbs_project_elements/refresh_tree"
  end

  def refresh_pbs_activity_ratios
    #No authorize required since everyone can select view project PBS
    puts "Params_activity = #{params[:wbs_activity_id]}"
    if params[:wbs_activity_id].empty? || params[:wbs_activity_id].nil?
      @pbs_activity_ratios = []
    else
      @wbs_activity = WbsActivity.find(params[:wbs_activity_id])
      @pbs_activity_ratios = @wbs_activity.wbs_activity_ratios
    end
  end
end
