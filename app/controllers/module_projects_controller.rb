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

class ModuleProjectsController < ApplicationController

  load_resource

  def pbs_element_matrix
    set_page_title 'Associate PBS-element'
    @project = Project.find(params[:project_id])
    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
  end

  def associate
    @project = Project.find(params[:project_id])
    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    @module_projects.each do |mp|
      mp.update_attribute('pbs_project_element_ids', params[:pbs_project_elements][mp.id.to_s])
    end
    redirect_to pbs_element_matrix_path(@project, :anchor => 'tabs-2')
  end

  def edit
    @module_project = ModuleProject.find(params[:id])
    @project = @module_project.project

    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects
    @initialization_module_project = @initialization_module.nil? ? nil : @module_projects.find_by_pemodule_id(@initialization_module.id)

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    set_page_title "Editing #{@module_project.pemodule.title}"
  end

  def update
    @module_project = ModuleProject.find(params[:id])
    @project = @module_project.project

    authorize! :alter_estimation_plan, @project

    #Update the current module_project view by copying the selected view and all its widgets
    if params['module_project']
      if params['module_project']['view_id'] != @module_project.view_id
        module_project_name = @module_project.to_s
        selected_view = View.find(params['module_project']['view_id'])
        new_view = selected_view
        #If the module_project view has changed
        if @module_project.view_id != selected_view.id
          #The view will be copied only if the view is used by another module
          if !selected_view.module_projects.empty?
            new_view = View.create(organization_id: @project.organization_id, name: "View for #{module_project_name}", description: "Dynamic created view for the #{module_project_name} module. Please rename the view's name and description if needed.")
            #We have to copy all the selected view's widgets in a new view for the current module_project
            selected_view.views_widgets.each do |view_widget|
              widget_est_val = view_widget.estimation_value
              in_out = widget_est_val.nil? ? "output" : widget_est_val.in_out
              estimation_value = @module_project.estimation_values.where('pe_attribute_id = ? AND in_out=?', view_widget.estimation_value.pe_attribute_id, in_out).first
              estimation_value_id = estimation_value.nil? ? nil : estimation_value.id
              widget_copy = ViewsWidget.create(view_id: new_view.id, module_project_id: @module_project.id, estimation_value_id: estimation_value_id, name: view_widget.name,
                                               show_name: view_widget.show_name, icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max,
                                               width: view_widget.width, height: view_widget.height, widget_type: view_widget.widget_type, position: view_widget.position)
            end
          end
        end
        #affect the view to the module_project
        @module_project.update_attributes(:view_id => new_view.id, :color => params['module_project']['color'])
      end
    end

    @module_project.estimation_values.each_with_index do |est_val, j|
      corresponding_am = AttributeModule.where('pemodule_id =? and pe_attribute_id = ?', @module_project.pemodule.id, est_val.pe_attribute.id).first
      if !corresponding_am.nil?
        unless corresponding_am.is_mandatory
          est_val.update_attribute('is_mandatory', params["is_mandatory_#{est_val.id}_#{est_val.in_out}"])
        end
      end
      est_val.update_attribute('description', params["description_#{est_val.id}_#{est_val.in_out}"])
    end

    # Get the project's max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

    redirect_to redirect(edit_module_project_path(@module_project)), notice: "#{I18n.t (:notice_module_project_successful_updated)}"
  end

  def module_projects_matrix
    @project = Project.find(params[:project_id])
    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
  end

  def associate_modules_projects
    @project = Project.find(params[:project_id])
    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
    @module_projects.each do |mp|
      mp.update_attribute('associated_module_project_ids', params[:module_projects][mp.id.to_s])
    end
    redirect_to edit_project_path(@project.id, :anchor => 'tabs-4')
  end


  def destroy
    @module_project = ModuleProject.find(params[:id])
    @project = @module_project.project

    authorize! :alter_estimation_plan, @project

    #re-set positions
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)
    position_x = @module_project.position_x

    #...finally, destroy object module_project
    @module_project.destroy

    #Update column module_projects link with initialization module
    unless @initialization_module_project.nil?
      mp = @project.module_projects.where('position_x = ?', position_x).order('position_y ASC').first
      mp.update_attribute('associated_module_project_ids', @initialization_module_project.id) unless mp.nil?
    end

    session[:module_project_id] = nil
    redirect_to edit_project_path(@project.id, :anchor => 'tabs-4')
  end

  def associate_module_project_to_ratios
    @module_project = ModuleProject.find(params[:module_project_id])
    @project = Project.find(params[:project_id])

    authorize! :alter_estimation_plan, @project

    @module_projects = @project.module_projects

    @module_projects.each do |mp|
      mp.update_attribute(:reference_value_id, params["module_projects_#{mp.id.to_s}"])
    end

    if params[:commit] == I18n.t('apply')
      flash[:notice] = I18n.t (:notice_module_project_successful_updated)
      redirect_to redirect(edit_module_project_path(@module_project.id, :anchor => 'tabs-3'))
    else
      redirect_to redirect(edit_project_path(@project.id, :anchor => 'tabs-4')), notice: "#{I18n.t (:notice_module_project_successful_updated)}"
    end
  end

  # Function to activate the current/selected module_project
  def activate_module_project
    session[:module_project_id] = params[:module_project_id]
    @module_project = ModuleProject.find(params[:module_project_id])

    authorize! :alter_estimation_plan, @project

    @module_projects ||= @project.module_projects
    @pbs_project_element = current_component

    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where("pemodule_id = ? AND project_id = ?", @initialization_module.id, @project.id).first  unless @initialization_module.nil?

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    @results = nil

    redirect_to main_app.dashboard_path(@project)
  end


  # Set the current balancing attribute for the Balancing-Module
  def selected_balancing_attribute
    session[:balancing_attribute_id] = params[:attribute_id]

    @project = Project.find(params[:project_id])
    @module_projects = @project.module_projects
    @pbs_project_element = current_component

    authorize! :alter_estimation_plan, @project

    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where("pemodule_id = ? AND project_id = ?", @initialization_module.id, @project.id).first  unless @initialization_module.nil?

    # Get the max X and Y positions of modules
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

    @results = nil

    #respond_to do |format|
    #  #format.js { render :partial => "module_projects/refresh_selected_module_data"}
    #  format.js { render :partial => "pbs_project_elements/refresh" }
    #end

  end

  # Show or not the module_project results view in dashboard
  def show_module_project_results_view
    if params[:module_project_id]
      @module_project = ModuleProject.find(params[:module_project_id])
      @project = @module_project.project
      @project_organization = @project.organization
      @module_projects = @project.module_projects
      @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
      @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max

      # when get click on the show_module_project_results_view button
      # if show_module_project_results_view is true, value will be changed to false and vice-versa
      case @module_project.show_results_view
        when true
          @module_project.update_attribute(:show_results_view, false)
        when false
          @module_project.update_attribute(:show_results_view, true)
        else
          @module_project.update_attribute(:show_results_view, true)
      end
    end
    @initialization_module_project = @initialization_module.nil? ? nil : @project.module_projects.find_by_pemodule_id(@initialization_module.id)

    respond_to do |format|
      format.js { render :js => "window.location.replace('#{dashboard_path(@project)}');"}
    end
  end

end
