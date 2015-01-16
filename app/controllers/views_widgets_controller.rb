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
#############################################################################

class ViewsWidgetsController < ApplicationController
  include ViewsWidgetsHelper
  include ProjectsHelper
  before_filter :load_current_project_data, only: [:create, :update, :destroy]

  def load_current_project_data
    #@project = Project.find(params[:project_id])
    #if @project
    @project_organization = @project.organization
    @module_projects ||= @project.module_projects
    #Get the initialization module_project
    @initialization_module_project ||= ModuleProject.where('pemodule_id = ? AND project_id = ?', @initialization_module.id, @project.id).first unless @initialization_module.nil?
    @module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1
    @module_positions_x = @project.module_projects.order(:position_x).all.map(&:position_x).max
    #end
  end

  # Get the module_project attributes grouped by Input and Ouput
  def get_module_project_attributes_input_output(module_project)
    # Get the possible attribute grouped by type (input, output)
    #attribute_modules = module_project.pemodule.attribute_modules
    #input_attribute_modules = attribute_modules.where('in_out IN (?)', ['input', 'both'])
    #output_attribute_modules = attribute_modules.where('in_out IN (?)', ['output', 'both'])
    #
    #module_project_attributes = []
    #input_attributes = []
    #output_attributes = []
    #
    ##for input attribute
    #input_attribute_modules.each do |attr_module|
    #  pe_attribute = attr_module.pe_attribute
    #  input_attributes << [pe_attribute, pe_attribute.id]
    #end
    #
    ##for output attribute
    #output_attribute_modules.each do |attr_module|
    #  pe_attribute = attr_module.pe_attribute
    #  output_attributes << [pe_attribute, pe_attribute.id]
    #end
    #
    #module_project_attributes << ["#{I18n.t(:inputs)}", input_attributes]
    #module_project_attributes << ["#{I18n.t(:outputs)}", output_attributes]
    ###module_project_attributes

    estimation_values = module_project.estimation_values.group_by{ |attr| attr.in_out }.sort()
  end


  def new
    @views_widget = ViewsWidget.new(params[:views_widget])
    @view_id = params[:view_id]
    @module_project = ModuleProject.find(params[:module_project_id])
    @pbs_project_element_id = current_component.id
    @project_pbs_project_elements = @module_project.project.pbs_project_elements#.reject{|i| i.is_root?}

    # Get the possible attribute grouped by type (input, output)
    @module_project_attributes = get_module_project_attributes_input_output(@module_project)

    #the view_widget type
    if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
      @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
    else
      @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
    end
  end

  def edit
    @views_widget = ViewsWidget.find(params[:id])
    @view_id = @views_widget.view_id
    @module_project = @views_widget.module_project_id.nil? ? ModuleProject.find(params[:module_project_id]) : @views_widget.module_project
    @pbs_project_element_id = @views_widget.pbs_project_element_id.nil? ? current_component.id : @views_widget.pbs_project_element_id
    @project_pbs_project_elements = @module_project.project.pbs_project_elements#.reject{|i| i.is_root?}

    # Get the possible attribute grouped by type (input, output)
    @module_project_attributes = get_module_project_attributes_input_output(@module_project)

    #the view_widget type
    if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
      @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
    else
      @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
    end
  end

  def create
    @views_widget = ViewsWidget.new(params[:views_widget])
    @view_id = params[:views_widget][:view_id]
    #@module_project = ModuleProject.find(params[:views_widget][:module_project_id])

    respond_to do |format|
      if @views_widget.save

        unless params["field"].blank?
          ProjectField.create( project_id: @project.id,
                               field_id: params["field"],
                               views_widget_id: @views_widget.id,
                               value: get_view_widget_data(current_module_project, @views_widget.id)[:value_to_show])
        end

        #flash[:notice] = "Widget ajouté avec succès"
        format.js { render :js => "window.location.replace('#{dashboard_path(@project)}');"}
      else
        flash[:error] = "Erreur d'ajout de Widget"
        @module_project = @views_widget.module_project_id.nil? ? ModuleProject.find(params[:module_project_id]) : @views_widget.module_project
        @pbs_project_element_id = params[:views_widget][:module_project_id].nil? ? current_component.id : params[:views_widget][:module_project_id]
        @project_pbs_project_elements = @project.pbs_project_elements#.reject{|i| i.is_root?}

        # Get the possible attribute grouped by type (input, output)
        @module_project_attributes = get_module_project_attributes_input_output(@module_project)

        #the view_widget type
        if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
          @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
        else
          @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
        end
        format.js { render action: :new }
      end
    end

    #redirect_to dashboard_path(@project)
  end

  def update
    @views_widget = ViewsWidget.find(params[:id])
    @view_id = @views_widget.view_id

    if params["field"].blank?
      pfs = @views_widget.project_fields
      pfs.destroy_all
    else
      pf = ProjectField.where(field_id: params["field"]).first
      if pf.nil?
        ProjectField.create(project_id: @project.id,
                            field_id: params["field"],
                            views_widget_id: @views_widget.id,
                            value: get_view_widget_data(@views_widget.module_project.id, @views_widget.id)[:value_to_show])
      else
        pf.value = get_view_widget_data(@views_widget.module_project.id, @views_widget.id)[:value_to_show]
        pf.save
      end
    end
    respond_to do |format|

      if @views_widget.update_attributes(params[:views_widget])
        #flash[:notice] = "Widget mis à jour avec succès"
        format.js { render :js => "window.location.replace('#{dashboard_path(@project)}');"}
      else
        flash[:error] = "Erreur lors de la mise à jour du Widget dans la vue"
        @module_project = @views_widget.module_project_id.nil? ? ModuleProject.find(params[:views_widget][:module_project_id]) : @views_widget.module_project
        @pbs_project_element = @views_widget.pbs_project_element_id.nil? ? current_component.id : @views_widget.pbs_project_element_id
        @project_pbs_project_elements = @project.pbs_project_elements#.reject{|i| i.is_root?}

        # Get the possible attribute grouped by type (input, output)
        @module_project_attributes = get_module_project_attributes_input_output(@module_project)

        #the view_widget type
        if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
          @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
        else
          @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
        end
        format.js { render action: :edit }
      end
    end

    #redirect_to dashboard_path(@project)
  end

  def destroy
    @views_widget = ViewsWidget.find(params[:id])
    @views_widget.destroy
    #render :partial => "views_widgets/refresh_views_widgets_results"
    redirect_to dashboard_path(@project)
  end

  def update_view_widget_positions
    view_id = params[:view_id]
    pos_x = "#{params[:position_x]}px"
    pos_y = "#{params[:position_y]}px"

    widgets_orders = params[:widgets_orders]
    if view_id != "" && view_id != "undefined"
      #if params["view_widget_id"] != "" && params["view_widget_id"] != "undefined"
      #  view_widget = ViewsWidget.find(params[:view_widget_id].to_i)
      #  pos_x = "#{params[:position_x]}px"
      #  pos_y = "#{params[:position_y]}px"
      #
      #  # Update the View Widget positions (left = position_x, top = position_y)
      #  view_widget.update_attributes(position_x: pos_x, position_y: pos_y)
      #end

      widgets_orders.each_with_index do |dashboard_widget_id, index|
        if dashboard_widget_id != ""
          view_widget_id = dashboard_widget_id.split("dashboard_widget_").last.to_i
          view_widget = ViewsWidget.find(view_widget_id)
          if view_widget
            # Update the View Widget positions (left = position_x, top = position_y)
            view_widget.update_attribute('position', index+1)
          end
        end
      end
    end
  end


  #Update the module_project corresponding data of view
  def update_widget_module_project_data
    module_project_id = params['module_project_id']
    if !module_project_id.nil? && module_project_id != 'undefined'
      @module_project = ModuleProject.find(module_project_id)
      #@module_project_attributes = @module_project.pemodule.pe_attributes
      # Get the possible attribute grouped by type (input, output)
      @module_project_attributes = get_module_project_attributes_input_output(@module_project)

      #the widget type
      if @module_project.pemodule.alias == Projestimate::Application::EFFORT_BREAKDOWN
        @views_widget_types = Projestimate::Application::BREAKDOWN_WIDGETS_TYPE
      else
        @views_widget_types = Projestimate::Application::GLOBAL_WIDGETS_TYPE
      end
    end
  end

end
