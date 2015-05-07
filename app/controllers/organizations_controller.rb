#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014-2015 Estimancy (http://www.estimancy.com)
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

class OrganizationsController < ApplicationController
  load_resource
  require 'rubygems'
  require 'securerandom'
  include ProjectsHelper
  include OrganizationsHelper

  def generate_report

    conditions = Hash.new
    params[:report].each do |i|
      unless i.last.blank? or i.last.nil?
        conditions[i.first] = i.last
      end
    end

    @organization = @current_organization
    check_if_organization_is_image(@organization)

    if params[:report_date][:start_date].blank? || params[:report_date][:end_date].blank?
      @projects = @organization.projects.where(is_model: false).where(conditions).where("title like ?", "%#{params[:title]}%").all
    else
      @projects = @organization.projects.where(is_model: false).where(conditions).where(:start_date => Time.parse(params[:report_date][:start_date])..Time.parse(params[:report_date][:end_date])).where("title like '%?%'").all
    end

    csv_string = CSV.generate(:col_sep => I18n.t(:general_csv_separator)) do |csv|
      if params[:with_header] == "checked"
        csv << [
            I18n.t(:project),
            I18n.t(:label_project_version),
            I18n.t(:label_product_name),
            I18n.t(:description),
            I18n.t(:start_date),
            I18n.t(:platform_category),
            I18n.t(:project_category),
            I18n.t(:acquisition_category),
            I18n.t(:project_area),
            I18n.t(:state),
            I18n.t(:creator),
        ] + @organization.fields.map(&:name)
      end

      tmp = Array.new
      @projects.each do |project|
        if can_show_estimation?(project)
          tmp = [
              project.title,
              project.version,
              project.product_name,
              ActionView::Base.full_sanitizer.sanitize(project.description).html_safe,
              project.start_date,
              project.platform_category,
              project.project_category,
              project.acquisition_category,
              project.project_area,
              project.estimation_status,
              project.creator
          ]
        elsif can_see_estimation?(project)
          #TODO
          tmp = update_selected_inline_columns(Project).map do |column|
            if column.caption == "description"
              ActionView::Base.full_sanitizer.sanitize(column.value_object(project)).html_safe
            else
              column.value_object(project)
            end
          end
        end

        @organization.fields.each do |field|
          pf = ProjectField.where(field_id: field.id, project_id: project.id).first
          tmp = tmp + [ pf.nil? ? '-' : convert_with_precision(pf.value.to_f / field.coefficient.to_f, user_number_precision) ]
        end


        csv << tmp
      end
    end
    send_data(csv_string.encode("ISO-8859-1"), :type => 'text/csv; header=present', :disposition => "attachment; filename=Rapport-#{Time.now}.csv")
  end

  def report
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)
  end

  def authorization
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs "Organizations" => "/organizationals_params", @organization.to_s => ""

    @groups = @organization.groups

    @organization_permissions = Permission.order('name').defined.select{ |i| i.object_type == "organization_super_admin_objects" }
    @global_permissions = Permission.order('name').defined.select{ |i| i.object_type == "general_objects" }
    @permission_projects = Permission.order('name').defined.select{ |i| i.object_type == "project_dependencies_objects" }
    @modules_permissions = Permission.order('name').defined.select{ |i| i.object_type == "module_objects" }
    @master_permissions = Permission.order('name').defined.select{ |i| i.is_master_permission }

    @permissions_classes_organization = @organization_permissions.map(&:category).uniq.sort
    @permissions_classes_globals = @global_permissions.map(&:category).uniq.sort
    @permissions_classes_projects = @permission_projects.map(&:category).uniq.sort
    @permissions_classes_masters = @master_permissions.map(&:category).uniq.sort
    @permissions_classes_modules = @modules_permissions.map(&:category).uniq.sort

    @project_security_levels = @organization.project_security_levels
  end

  def setting
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs "Organizations" => "/organizationals_params", @organization.to_s => ""

    @technologies = @organization.organization_technologies
    @fields = @organization.fields
    @work_element_types = @organization.work_element_types

    @organization_profiles = @organization.organization_profiles

    @organization_group = @organization.groups

    @estimation_models = @organization.projects.where(:is_model => true)
  end

  def module_estimation
    @organization = Organization.find(params[:organization_id])

    check_if_organization_is_image(@organization)

    set_breadcrumbs "Organizations" => "/organizationals_params", @organization.to_s => ""

    @guw_models = @organization.guw_models
    @wbs_activities = @organization.wbs_activities
    @size_units = SizeUnit.all
    @technologies = @organization.organization_technologies
    @size_unit_types = @organization.size_unit_types
    @amoa_models = @organization.amoa_models
  end

  def users
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs "Organizations" => "/organizationals_params", @organization.to_s => ""
  end

  def estimations
    @organization = Organization.find(params[:organization_id])
    check_if_organization_is_image(@organization)

    set_breadcrumbs "Organizations" => "/organizationals_params", @organization.to_s => ""

    @projects = @organization.projects.where(is_model: false).all
  end

  # New organization from image
  def new_organization_from_image
  end

  # Method that execute the duplication: duplicate estimation model for organization
  def execute_duplication(project_id, new_organization_id)
    #begin
      old_prj = Project.find(project_id)
      new_organization = Organization.find(new_organization_id)

      new_prj = old_prj.amoeba_dup #amoeba gem is configured in Project class model
      new_prj.organization_id = new_organization_id
      new_prj.title = old_prj.title
      new_prj.description = old_prj.description
      new_estimation_status = new_organization.estimation_statuses.where(copy_id: new_prj.estimation_status_id).first
      new_estimation_status_id = new_estimation_status.nil? ? nil : new_estimation_status.id
      new_prj.estimation_status_id = new_estimation_status_id

      if old_prj.is_model
        new_prj.is_model = true
      else
        new_prj.is_model = false
      end

      if new_prj.save
        old_prj.save #Original project copy number will be incremented to 1

        #Managing the component tree : PBS
        pe_wbs_product = new_prj.pe_wbs_projects.products_wbs.first

        # For PBS
        new_prj_components = pe_wbs_product.pbs_project_elements
        new_prj_components.each do |new_c|
          new_ancestor_ids_list = []
          new_c.ancestor_ids.each do |ancestor_id|
            ancestor_id = PbsProjectElement.find_by_pe_wbs_project_id_and_copy_id(new_c.pe_wbs_project_id, ancestor_id).id
            new_ancestor_ids_list.push(ancestor_id)
          end
          new_c.ancestry = new_ancestor_ids_list.join('/')
          new_c.save
        end

        #Update the project securities for the current user who create the estimation from model
        #if params[:action_name] == "create_project_from_template"
        if old_prj.is_model
          creator_securities = old_prj.creator.project_securities_for_select(new_prj.id)
          unless creator_securities.nil?
            creator_securities.update_attribute(:user_id, current_user.id)
          end
        end
        #Other project securities for groups
        new_prj.project_securities.where('group_id IS NOT NULL').each do |project_security|
          new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
          new_group = new_organization.groups.where(copy_id: project_security.group_id).first
          if new_security_level.nil? || new_group.nil?
            project_security.destroy
          else
            project_security.update_attributes(project_security_level_id: new_security_level.id, group_id: new_group.id)
          end
        end

        #Other project securities for users
        new_prj.project_securities.where('user_id IS NOT NULL').each do |project_security|
          new_security_level = new_organization.project_security_levels.where(copy_id: project_security.project_security_level_id).first
          if new_security_level.nil?
            project_security.destroy
          else
            project_security.update_attributes(project_security_level_id: new_security_level.id)
          end
        end

        # For ModuleProject associations
        old_prj.module_projects.group(:id).each do |old_mp|
          new_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, old_mp.id)

          # ModuleProject Associations for the new project
          old_mp.associated_module_projects.each do |associated_mp|
            new_associated_mp = ModuleProject.where('project_id = ? AND copy_id = ?', new_prj.id, associated_mp.id).first
            new_mp.associated_module_projects << new_associated_mp
          end

          # if the module_project view is nil
          #if new_mp.view.nil?
          #  default_view = new_organization.views.where('pemodule_id = ? AND is_default_view = ?', new_mp.pemodule_id, true).first
          #  if default_view.nil?
          #    default_view = View.create(name: "#{new_mp} view", description: "", pemodule_id: new_mp.pemodule_id, organization_id: new_organization_id)
          #  end
          #  new_mp.update_attribute(:view_id, default_view.id)
          #end

          #Recreate view for all moduleproject as the projects are not is the same organization
          #Copy the views and widgets for the new project
          #mp_default_view =
          #if old_mp.view.nil?
          #
          #else
          #
          #end
          new_view = View.create(organization_id: new_organization_id, name: "#{new_prj.to_s} : view for #{new_mp.to_s}", description: "Please rename the view's name and description if needed.")
          # We have to copy all the selected view's widgets in a new view for the current module_project
          if old_mp.view
            old_mp_view_widgets = old_mp.view.views_widgets.all
            old_mp_view_widgets.each do |view_widget|
              new_view_widget_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, view_widget.module_project_id)
              new_view_widget_mp_id = new_view_widget_mp.nil? ? nil : new_view_widget_mp.id
              widget_est_val = view_widget.estimation_value
              unless widget_est_val.nil?
                in_out = widget_est_val.in_out
                widget_pe_attribute_id = widget_est_val.pe_attribute_id
                unless new_view_widget_mp.nil?
                  new_estimation_value = new_view_widget_mp.estimation_values.where('pe_attribute_id = ? AND in_out=?', widget_pe_attribute_id, in_out).last
                  estimation_value_id = new_estimation_value.nil? ? nil : new_estimation_value.id
                  widget_copy = ViewsWidget.create(view_id: new_view.id, module_project_id: new_view_widget_mp_id, estimation_value_id: estimation_value_id, name: view_widget.name, show_name: view_widget.show_name,
                                                   icon_class: view_widget.icon_class, color: view_widget.color, show_min_max: view_widget.show_min_max, widget_type: view_widget.widget_type,
                                                   width: view_widget.width, height: view_widget.height, position: view_widget.position, position_x: view_widget.position_x, position_y: view_widget.position_y)

                  pf = ProjectField.where(project_id: new_prj.id, views_widget_id: view_widget.id).first
                  unless pf.nil?
                    new_field = new_organization.fields.where(copy_id: pf.field_id).first
                    pf.views_widget_id = widget_copy.id
                    pf.field_id = new_field.nil? ? nil : new_field.id
                    pf.save
                  end
                end
              end
            end
          end
          #update the new module_project view
          new_mp.update_attribute(:view_id, new_view.id)
          ###end

          #Update the Unit of works's groups
          new_mp.guw_unit_of_work_groups.each do |guw_group|
            new_pbs_project_element = new_prj_components.find_by_copy_id(guw_group.pbs_project_element_id)
            new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id

            #technology
            new_technology = new_organization.organization_technologies.where(copy_id: guw_group.organization_technology_id).first
            new_technology_id = new_technology.nil? ? nil : new_technology.id

            guw_group.update_attributes(pbs_project_element_id: new_pbs_project_element_id, organization_technology_id: new_technology_id)

            # Update the group unit of works and attributes
            guw_group.guw_unit_of_works.each do |guw_uow|
              new_uow_mp = ModuleProject.find_by_project_id_and_copy_id(new_prj.id, guw_uow.module_project_id)
              new_uow_mp_id = new_uow_mp.nil? ? nil : new_uow_mp.id

              #PBS
              new_pbs = new_prj_components.find_by_copy_id(guw_uow.pbs_project_element_id)
              new_pbs_id = new_pbs.nil? ? nil : new_pbs.id

              # GuwModel
              new_guw_model = new_organization.guw_models.where(copy_id: guw_uow.guw_model_id).first
              new_guw_model_id = new_guw_model.nil? ? nil : new_guw_model.id

              # guw_work_unit
              if !new_guw_model.nil?
                new_guw_work_unit = new_guw_model.guw_work_units.where(copy_id: guw_uow.guw_work_unit_id).first
                new_guw_work_unit_id = new_guw_work_unit.nil? ? nil : new_guw_work_unit.id

                #Type
                new_guw_type = new_guw_model.guw_types.where(copy_id: guw_uow.guw_type_id).first
                new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

                #Complexity
                if !guw_uow.guw_complexity_id.nil? && !new_guw_type.nil?
                  new_complexity = new_guw_type.guw_complexities.where(copy_id: guw_uow.guw_complexity_id).first
                  new_complexity_id = new_complexity.nil? ? nil : new_complexity.id
                else
                  new_complexity_id = nil
                end

              else
                new_guw_work_unit_id = nil
                new_guw_type_id = nil
                new_complexity_id = nil
              end

              #Technology
              uow_new_technology = new_organization.organization_technologies.where(copy_id: guw_uow.organization_technology_id).first
              uow_new_technology_id = uow_new_technology.nil? ? nil : uow_new_technology.id

              guw_uow.update_attributes(module_project_id: new_uow_mp_id, pbs_project_element_id: new_pbs_id, guw_model_id: new_guw_model_id,
                                        guw_type_id: new_guw_type_id, guw_work_unit_id: new_guw_work_unit_id, guw_complexity_id: new_complexity_id,
                                        organization_technology_id: uow_new_technology_id)
            end
          end

          # UOW-INPUTS
          new_mp.uow_inputs.each do |uo|
            new_pbs_project_element = new_prj_components.find_by_copy_id(uo.pbs_project_element_id)
            new_pbs_project_element_id = new_pbs_project_element.nil? ? nil : new_pbs_project_element.id
            uo.update_attribute(:pbs_project_element_id, new_pbs_project_element_id)
          end

          #WBS-ACTIVITY-INPUTS
          new_mp.wbs_activity_inputs.each do |activity_input|
            new_wbs_activity = new_organization.wbs_activities.where(copy_id: activity_input.wbs_activity_id).first
            unless new_wbs_activity.nil?
              new_wbs_activity_ratio = new_wbs_activity.wbs_activity_ratios.where(copy_id: activity_input.wbs_activity_ratio_id).first
              unless new_wbs_activity_ratio.nil?
                activity_input.update_attributes(wbs_activity_id: new_wbs_activity.id, wbs_activity_ratio_id: new_wbs_activity_ratio.id)
              end
            end
          end

          ["input", "output"].each do |io|
            new_mp.pemodule.pe_attributes.each do |attr|
              old_prj.pbs_project_elements.each do |old_component|
                new_prj_components.each do |new_component|
                  ev = new_mp.estimation_values.where(pe_attribute_id: attr.id, in_out: io).first
                  unless ev.nil?
                    ev.string_data_low[new_component.id.to_i] = ev.string_data_low.delete old_component.id
                    ev.string_data_most_likely[new_component.id.to_i] = ev.string_data_most_likely.delete old_component.id
                    ev.string_data_high[new_component.id.to_i] = ev.string_data_high.delete old_component.id
                    ev.string_data_probable[new_component.id.to_i] = ev.string_data_probable.delete old_component.id
                    ev.save
                  end
                end
              end
            end
          end
        end

      else
        new_prj = nil
      end

    #rescue
      #new_prj = nil
    #end

    new_prj
  end


  # Create New organization from selected image organization
  # Or duplicate current selected organization
  def create_organization_from_image
    authorize! :manage, Organization

    case params[:action_name]
      #Duplicate organization
      when "copy_organization"
        organization_image = Organization.find(params[:organization_id])

      #Create the organization from image organization
      when "new_organization_from_image"
        organization_image_id = params[:organization_image]
        if organization_image_id.nil?
          flash[:warning] = "Veuillez sélectionner une organisation image pour continuer"
        else
          organization_image = Organization.find(organization_image_id)
          @organization_name = params[:organization_name]
          @firstname = params[:firstname]
          @lastname = params[:lastname]
          @email = params[:email]
          @login_name = params[:identifiant]
          @password = params[:password]
          if @password.empty?
            @password = SecureRandom.hex(8)
          end
          change_password_required = params[:change_password_required]
        end
      else
        flash[:error] = "Aucune organization sélectionnée"
        redirect_to :back and return
    end

    if organization_image.nil?
      flash[:warning] = "Veuillez sélectionner une organisation pour continuer"
    else
      new_organization = organization_image.amoeba_dup

      if params[:action_name] == "new_organization_from_image"
        new_organization.name = @organization_name
      elsif params[:action_name] == "copy_organization"
        new_organization.description << "\n \n Cette organisation est une copie de l'organisation #{organization_image.name}."
        new_organization.description << "\n #{I18n.l(Time.now)} : #{I18n.t(:organization_copied_by, username: current_user.name)}"
      end
      new_organization.is_image_organization = false

      if new_organization.save
        organization_image.save #Original organization copy number will be incremented to 1

        #Copy the organization estimation_statuses workflow and groups/roles
        new_estimation_statuses = new_organization.estimation_statuses
        new_estimation_statuses.each do |estimation_status|
          copied_status = EstimationStatus.find(estimation_status.copy_id)

          #Get the to_transitions for the Statuses Workflow
          copied_status.to_transition_statuses.each do |to_transition|
            new_to_transition = new_estimation_statuses.where(copy_id: to_transition.id).first
            unless new_to_transition.nil?
              StatusTransition.create(from_transition_status_id: estimation_status.id, to_transition_status_id: new_to_transition.id)
            end
          end
        end

        #Get the estimation_statuses role / by group
        new_organization.project_security_levels.each do |project_security_level|
          project_security_level.estimation_status_group_roles.each do |group_role|
            new_group = new_organization.groups.where(copy_id: group_role.group_id).first
            estimation_status = new_organization.estimation_statuses.where(copy_id: group_role.estimation_status_id).first
            unless estimation_status.nil?
              group_role.update_attributes(organization_id: new_organization.id, estimation_status_id: estimation_status.id, group_id: new_group.id)
            end
          end
        end

        #Then copy the image organization estimation models
        if params[:action_name] == "new_organization_from_image"
          # Create a user in the Admin group of the new organization
          admin_user = User.new(first_name: @firstname, last_name: @lastname, login_name: @login_name, email: @email, password: @password, password_confirmation: @password, super_admin: false)
          # Add the user to the created organization
          admin_group = new_organization.groups.where(name: '*USER').first #first_or_create(name: "*USER", organization_id: new_organization.id, description: "Groupe créé par défaut dans l'organisation pour la gestion des administrateurs")
          unless admin_group.nil?
            admin_user.groups << admin_group
            admin_user.save
          end

        elsif params[:action_name] == "copy_organization"
          # add users to groups
          organization_image.groups.each do |group|
            new_group = new_organization.groups.where(copy_id: group.id).first
            unless new_group.nil?
              new_group.users = group.users
              new_group.save
            end
          end
        end


        # Copy the WBS-Activities modules's Models instances
        organization_image.wbs_activities.each do |old_wbs_activity|
          new_wbs_activity = old_wbs_activity.amoeba_dup   #amoeba gem is configured in WbsActivity class model
          new_wbs_activity.organization_id = new_organization.id

          new_wbs_activity.transaction do
            if new_wbs_activity.save
              old_wbs_activity.save  #Original WbsActivity copy number will be incremented to 1

              #we also have to save to wbs_activity_ratio
              old_wbs_activity.wbs_activity_ratios.each do |ratio|
                ratio.save
              end

              #get new WBS Ratio elements
              new_wbs_activity_ratio_elts = []
              new_wbs_activity.wbs_activity_ratios.each do |ratio|
                ratio.wbs_activity_ratio_elements.each do |ratio_elt|
                  new_wbs_activity_ratio_elts << ratio_elt

                  #Update ratio elements profiles
                  ratio_elt.wbs_activity_ratio_profiles.each do |activity_ratio_profile|
                    new_organization_profile = new_organization.organization_profiles.where(copy_id: activity_ratio_profile.organization_profile_id).first
                    unless new_organization_profile.nil?
                      activity_ratio_profile.update_attribute(:organization_profile_id, new_organization_profile.id)
                    end
                  end
                end
              end

              #Managing the component tree
              old_wbs_activity_elements = old_wbs_activity.wbs_activity_elements.order('ancestry_depth asc')
              old_wbs_activity_elements.each do |old_elt|
                new_elt = old_elt.amoeba_dup
                new_elt.wbs_activity_id = new_wbs_activity.id
                new_elt.save#(:validate => false)

                unless new_elt.is_root?
                  new_ancestor_ids_list = []
                  new_elt.ancestor_ids.each do |ancestor_id|
                    ancestor = WbsActivityElement.find_by_wbs_activity_id_and_copy_id(new_elt.wbs_activity_id, ancestor_id)
                    unless ancestor.nil?
                      ancestor_id = ancestor.id
                      new_ancestor_ids_list.push(ancestor_id)
                    end
                  end
                  new_elt.ancestry = new_ancestor_ids_list.join('/')

                  corresponding_ratio_elts = new_wbs_activity_ratio_elts.select { |ratio_elt| ratio_elt.wbs_activity_element_id == new_elt.copy_id}.each do |ratio_elt|
                    ratio_elt.update_attribute('wbs_activity_element_id', new_elt.id)
                  end

                  new_elt.save(:validate => false)
                end
              end
            else
              flash[:error] = "#{new_wbs_activity.errors.full_messages.to_sentence}"
            end
          end

          # Update all the new organization module_project's guw_model with the current guw_model
          wbs_activity_copy_id = old_wbs_activity.id
          new_organization.module_projects.where(wbs_activity_id: wbs_activity_copy_id).update_all(wbs_activity_id: new_wbs_activity.id)
        end

        # copy the organization's projects
        organization_image.projects.all.each do |est_model|
          #DuplicateWorker.perform(est_model.id, new_organization.id)
          new_template = execute_duplication(est_model.id, new_organization.id)
          unless new_template.nil?
            new_template.is_model = est_model.is_model
            #new_template.original_model_id = nil
            new_template.save
          end
        end

        #update the project's ancestry
        new_organization.projects.all.each do |project|

          unless project.original_model_id.nil?
            new_original_model = new_organization.projects.where(copy_id: project.original_model_id).first
            new_original_model_id = new_original_model.nil? ? nil : new_original_model.id
            project.original_model_id = new_original_model_id
            project.save
          end

          unless project.ancestry.nil?
            new_ancestor_ids_list = []
            project.ancestor_ids.each do |ancestor_id|
              ancestor = new_organization.projects.where(copy_id: ancestor_id).first
              unless ancestor.nil?
                #ancestor_id = ancestor.id
                new_ancestor_ids_list.push(ancestor.id)
              end
            end
            project.ancestry = new_ancestor_ids_list.join('/')
            project.save
          end
        end

        # Update the Expert Judgement modules's Models instances
        new_organization.expert_judgement_instances.each do |expert_judgment|
          # Update all the new organization module_project's guw_model with the current guw_model
          expert_judgment_copy_id = expert_judgment.copy_id
          new_organization.module_projects.where(expert_judgement_instance_id: expert_judgment_copy_id).update_all(expert_judgement_instance_id: expert_judgment.id)
        end

        # Update the modules's GE Models instances
        new_organization.ge_models.each do |ge_model|
          # Update all the new organization module_project's guw_model with the current guw_model
          ge_copy_id = ge_model.copy_id
          new_organization.module_projects.where(ge_model_id: ge_copy_id).update_all(ge_model_id: ge_model.id)
        end

        # Copy the modules's GUW Models instances
        new_organization.guw_models.each do |guw_model|

          # Update all the new organization module_project's guw_model with the current guw_model
          copy_id = guw_model.copy_id
          new_organization.module_projects.where(guw_model_id: copy_id).update_all(guw_model_id: guw_model.id)

          guw_model.guw_types.each do |guw_type|

            # Copy the complexities technologies
            guw_type.guw_complexities.each do |guw_complexity|
              # Copy the complexities technologie
              guw_complexity.guw_complexity_technologies.each do |guw_complexity_technology|
                new_organization_technology = new_organization.organization_technologies.where(copy_id: guw_complexity_technology.organization_technology_id).first
                unless new_organization_technology.nil?
                  guw_complexity_technology.update_attribute(:organization_technology_id, new_organization_technology.id)
                end
              end

              # Copy the complexities units of works
              guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
                new_guw_work_unit = guw_model.guw_work_units.where(copy_id: guw_complexity_work_unit.guw_work_unit_id).first
                unless new_guw_work_unit.nil?
                  guw_complexity_work_unit.update_attribute(:guw_work_unit_id, new_guw_work_unit.id)
                end
              end
            end

            #Guw UnitOfWorkAttributes
            guw_type.guw_unit_of_works.each do |guw_unit_of_work|
              guw_unit_of_work.guw_unit_of_work_attributes.each do |guw_uow_attr|
                new_guw_type = guw_model.guw_types.where(copy_id: guw_uow_attr.guw_type_id).first
                new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

                new_guw_attribute = guw_model.guw_attributes.where(copy_id: guw_uow_attr.guw_attribute_id).first
                new_guw_attribute_id = new_guw_attribute.nil? ? nil : new_guw_attribute.id

                guw_uow_attr.update_attributes(guw_type_id: new_guw_type_id, guw_attribute_id: new_guw_attribute_id)

              end
            end

            # Copy the GUW-attribute-complexity
            #guw_type.guw_type_complexities.each do |guw_type_complexity|
            #  guw_type_complexity.guw_attribute_complexities.each do |guw_attr_complexity|
            #
            #    new_guw_attribute = guw_model.guw_attributes.where(copy_id: guw_attr_complexity.guw_attribute_id).first
            #    new_guw_attribute_id = new_guw_attribute.nil? ? nil : new_guw_attribute.id
            #
            #    new_guw_type = guw_model.guw_types.where(copy_id: guw_type_complexity.guw_type_id).first
            #    new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id
            #
            #    guw_attr_complexity.update_attributes(guw_type_id: new_guw_type_id, guw_attribute_id: new_guw_attribute_id)
            #  end
            #end
          end

          guw_model.guw_attributes.each do |guw_attribute|
            guw_attribute.guw_attribute_complexities.each do |guw_attr_complexity|
              new_guw_type = guw_model.guw_types.where(copy_id: guw_attr_complexity.guw_type_id).first
              new_guw_type_id = new_guw_type.nil? ? nil : new_guw_type.id

              unless new_guw_type.nil?
                new_guw_type_complexity = new_guw_type.guw_type_complexities.where(copy_id: guw_attr_complexity.guw_type_complexity_id).first
                new_guw_type_complexity_id = new_guw_type_complexity.nil? ? nil : new_guw_type_complexity.id

                guw_attr_complexity.update_attributes(guw_type_id: new_guw_type_id, guw_type_complexity_id: new_guw_type_complexity_id )

              end
            end
          end
        end

        flash[:notice] = I18n.t(:notice_organization_successful_created)
      else
        flash[:error] = I18n.t('errors.messages.not_saved')
      end
    end

    #redirect_to :back
    respond_to do |format|
      format.html { redirect_to :back }
      format.js { render :js => "window.location.replace('/organizationals_params');"}
    end
  end

  def new
    authorize! :create_organizations, Organization

    set_page_title 'Organizations'
    @organization = Organization.new
    @groups = @organization.groups
  end

  def edit
    #authorize! :edit_organizations, Organization
    authorize! :show_organizations, Organization

    set_page_title 'Organizations'
    @organization = Organization.find(params[:id])

    set_breadcrumbs "Organizations" => "/organizationals_params", @organization.to_s => ""

    @attributes = PeAttribute.defined.all
    @attribute_settings = AttributeOrganization.all(:conditions => {:organization_id => @organization.id})

    @complexities = @organization.organization_uow_complexities

    @factors = Factor.order("factor_type")

    @ot = @organization.organization_technologies.first
    @unitofworks = @organization.unit_of_works

    @users = @organization.users
    @fields = @organization.fields

    @organization_profiles = @organization.organization_profiles

    @work_element_types = @organization.work_element_types
  end

  def refresh_value_elements
    @size_unit = SizeUnit.find(params[:size_unit_id])
    @technologies = OrganizationTechnology.all
  end

  def create
    authorize! :create_organizations, Organization

    @organization = Organization.new(params[:organization])

    # Organization's projects selected columns
    @organization.project_selected_columns = Project.default_selected_columns

    # Add current_user to the organization
    @organization.users << current_user

    #A la sauvegarde, on crée des sous traitants
    if @organization.save

      #Create default the size unit type's
      size_unit_types = [
          ['New', 'new', ""],
          ['Modified', 'new', ""],
          ['Reused', 'new', ""],
      ]
      size_unit_types.each do |i|

        sut = SizeUnitType.create(:name => i[0], :alias => i[1], :description => i[2], :organization_id => @organization.id)

        @organization.organization_technologies.each do |ot|
          SizeUnit.all.each do |su|
            TechnologySizeType.create(organization_id: sut.organization_id, organization_technology_id: ot.id, size_unit_id: su.id, size_unit_type_id: sut.id, value: 1)
          end
        end
      end

      uow = [
          ['Données', 'data', "Création, modification, suppression, duplication de composants d'une base de données (tables, fichiers). Une UO doit être comptée pour chaque entité métier. Seules les entités métier sont comptabilisées."],
          ['Traitement', 'traitement', 'Création, modification, suppression, duplication de composants de visualisation, gestion de données, activation de fonctionnalités avec une interface de type Caractère (terminal passif).'],
          ['Batch', 'batch', "Création, modification, suppression, duplication de composants d'extraction ou de MAJ de données d'une source de données persistante. Par convention, cette UO ne couvre pas les interfaces. Cette UO couvre le nettoyage et la purge des tables."],
          ['Interfaces', 'interface', "Création, modification, suppression, duplication de composants d'interface de type : Médiation, Conversion, Transcodification, Transformation (les transformations sont implémentées en langage de programmation). Les 'Historisation avec clés techniques générée' sont à comptabiliser en 'Règle de gestion'"]
      ]
      uow.each do |i|
        @organization.unit_of_works.create(:name => i[0], :alias => i[1], :description => i[2], :state => 'defined')
      end

      #A la création de l'organixation, on crée les complexités de facteurs à partir des defined ( les defined ont organization_id => nil)
      OrganizationUowComplexity.where(organization_id: nil).each do |o|
        ouc = OrganizationUowComplexity.new(name: o.name , organization_id: @organization.id, description: o.description, value: o.value, factor_id: o.factor_id, is_default: o.is_default, :state => 'defined')
        ouc.save(validate: false)
      end

      #Et la, on crée les complexités des unités d'oeuvres par défaut
      levels = [
          ['Simple', 'simple', "Simple", 1, "defined"],
          ['Moyen', 'moyen', "Moyen", 2, "defined"],
          ['Complexe', 'complexe', "Complexe", 4, "defined"]
      ]
      levels.each do |i|
        @organization.unit_of_works.each do |uow|
          ouc = OrganizationUowComplexity.new(:name => i[0], :alias => i[1], :description => i[2], :state => i[4], :unit_of_work_id => uow.id, :organization_id => @organization.id)
          ouc.save(validate: false)

          @organization.size_unit_types.each do |sut|
            SizeUnitTypeComplexity.create(size_unit_type_id: sut.id, organization_uow_complexity_id: ouc.id, value: i[3])
          end
        end
      end

      #A la sauvegarde, on copies des technologies
      Technology.all.each do |technology|
        ot = OrganizationTechnology.new(name: technology.name, alias: technology.name, description: technology.description, organization_id: @organization.id)
        ot.save(validate: false)
      end

      # Add MasterData Profiles to Organization
      Profile.all.each do |profile|
        op = OrganizationProfile.new(organization_id: @organization.id, name: profile.name, description: profile.description, cost_per_hour: profile.cost_per_hour)
        op.save
      end

      # Add some Estimations statuses in organization
      estimation_statuses = [
          ['0', 'preliminary', "Préliminaire", "999999", "Statut initial lors de la création de l'estimation"],
          ['1', 'in_progress', "En cours", "3a87ad", "En cours de modification"],
          ['2', 'in_review', "Relecture", "f89406", "En relecture"],
          ['3', 'checkpoint', "Contrôle", "b94a48", "En phase de contrôle"],
          ['4', 'released', "Confirmé", "468847", "Phase finale d'une estimation qui arrive à terme et qui sera retenue comme une version majeure"],
          ['5', 'rejected', "Rejeté", "333333", "L'estimation dans ce statut est rejetée et ne sera pas poursuivi"]
      ]
      estimation_statuses.each do |i|
        status = EstimationStatus.create(organization_id: @organization.id, status_number: i[0], status_alias: i[1], name: i[2], status_color: i[3], description: i[4])
      end

      #Add a default view for widgets
      view = View.create(:name => "Default view",
                         :description => "Default widgets's default view. If no view is selected for module project, this view will be automatically selected.",
                         :organization_id => @organization.id)

      redirect_to redirect_apply(edit_organization_path(@organization)), notice: "#{I18n.t(:notice_organization_successful_created)}"
    else
      render action: 'new'
    end
  end

  def update
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:id])
    if @organization.update_attributes(params[:organization])

      OrganizationUowComplexity.where(organization_id: @organization.id).each do |ouc|
        @organization.size_unit_types.each do |sut|
          sutc = SizeUnitTypeComplexity.where(size_unit_type_id: sut.id, organization_uow_complexity_id: ouc.id).first
          if sutc.nil?
            SizeUnitTypeComplexity.create(size_unit_type_id: sut.id, organization_uow_complexity_id: ouc.id)
          end
        end
      end

      flash[:notice] = I18n.t (:notice_organization_successful_updated)
      redirect_to redirect_apply(edit_organization_path(@organization), nil, '/organizationals_params')
    else
      @attributes = PeAttribute.defined.all
      @attribute_settings = AttributeOrganization.all(:conditions => {:organization_id => @organization.id})
      @complexities = @organization.organization_uow_complexities
      @ot = @organization.organization_technologies.first
      @unitofworks = @organization.unit_of_works
      @factors = Factor.order("factor_type")
      @technologies = OrganizationTechnology.all
      @size_unit_types = SizeUnitType.all
      @organization_profiles = @organization.organization_profiles
      @groups = @organization.groups
      @organization_group = @organization.groups
      @wbs_activities = @organization.wbs_activities
      @projects = @organization.projects
      @fields = @organization.fields
      @size_units = SizeUnit.all
      @guw_models = @organization.guw_models

      render action: 'edit'
    end
  end

  def confirm_organization_deletion
    @organization = Organization.find(params[:organization_id])
    authorize! :manage, Organization
  end

  def destroy
    authorize! :manage, Organization

    @organization = Organization.find(params[:id])
    @organization_id = @organization.id

    case params[:commit]
      when I18n.t('delete')
        if params[:yes_confirmation] == 'selected'
          @organization.destroy
          if session[:organization_id] == params[:id]
            session[:organization_id] = current_user.organizations.first  #session[:organization_id] = nil
          end
          flash[:notice] = I18n.t(:notice_organization_successful_deleted)
          redirect_to '/organizationals_params' and return

        else
          flash[:warning] = I18n.t('warning_need_organization_check_box_confirmation')
          render :template => 'organizations/confirm_organization_deletion', :locals => {:organization_id => @organization_id}
        end

      when I18n.t('cancel')
        redirect_to '/organizationals_params' and return
      else
        render :template => 'projects/confirm_organization_deletion', :locals => {:organization_id => @organization_id}
    end
  end

  def organizationals_params
    set_page_title 'Organizational Parameters'

    set_breadcrumbs "Organizations" => "/organizationals_params", "Liste des organizations" => ""

    if current_user.super_admin?
      @organizations = Organization.all
    elsif can?(:manage, :all)
      @organizations = Organization.all.reject{|org| org.is_image_organization}
    else
      @organizations = current_user.organizations.all.reject{|org| org.is_image_organization}
    end

    @size_units = SizeUnit.all
    @factors = Factor.order("factor_type")
  end

  def export
    @organization = Organization.find(params[:organization_id])
    csv_string = CSV.generate(:col_sep => ",") do |csv|
      csv << ['Prénom', 'Nom', 'Email', 'Login', 'Groupes']
      @organization.users.each do |user|
        csv << [user.first_name, user.last_name, user.email, user.login_name] + user.groups.map(&:name)
      end
    end
    send_data(csv_string.encode("ISO-8859-1"), :type => 'text/csv; header=present', :disposition => "attachment; filename='modele_import_utilisateurs.csv'")
  end

  def import_user
    sep = "#{params[:separator].blank? ? I18n.t(:general_csv_separator) : params[:separator]}"
    error_count = 0
    file = params[:file]
    encoding = params[:encoding]
    #begin
      CSV.open(file.path, 'r', :quote_char => "\"", :row_sep => :auto, :col_sep => sep, :encoding => "ISO-8859-1:ISO-8859-1") do |csv|
        csv.each_with_index do |row, i|
          unless i == 0
            password = SecureRandom.hex(8)

            user = User.where(login_name: row[3]).first
            if user.nil?

              u = User.new(first_name: row[0],
                           last_name: row[1],
                           email: row[2],
                           login_name: row[3],
                           id_connexion: row[3],
                           super_admin: false,
                           password: password,
                           password_confirmation: password,
                           language_id: params[:language_id].to_i,
                           initials: "#{row[0].first}#{row[1].first}",
                           time_zone: "Paris",
                           object_per_page: 50,
                           auth_type: "Application",
                           number_precision: 2)

              u.save(validate: false)

              OrganizationsUsers.create(organization_id: @current_organization.id,
                                        user_id: u.id)
              (row.size - 4).times do |i|
                group = Group.where(name: row[4 + i], organization_id: @current_organization.id).first
                begin
                  GroupsUsers.create(group_id: group.id,
                                     user_id: u.id)
                rescue
                  # nothing
                end
              end
            end
          end
        end
      end
    #rescue
    #  flash[:error] = "Une erreur est survenue durant l'import du fichier. Vérifier l'encodage du fichier (ISO-8859-1 pour Windows, utf-8 pour Mac) ou le caractère de séparateur du fichier"
    #end
    redirect_to organization_users_path(@current_organization)
  end

  def set_technology_size_type_abacus
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:organization])
    @technologies = @organization.organization_technologies
    @size_unit_types = @organization.size_unit_types
    @size_units = SizeUnit.all

    @technologies.each do |technology|
      @size_unit_types.each do |sut|
        @size_units.each do |size_unit|

          #size_unit = params[:size_unit]["#{su.id}"].to_i

          value = params[:abacus]["#{size_unit.id}"]["#{technology.id}"]["#{sut.id}"].to_f

          unless value.nil?
            t = TechnologySizeType.where( organization_id: @organization.id,
                                          organization_technology_id: technology.id,
                                          size_unit_id: size_unit.id,
                                          size_unit_type_id: sut.id).first

            if t.nil?
              TechnologySizeType.create(organization_id: @organization.id,
                                        organization_technology_id: technology.id,
                                        size_unit_id: size_unit.id,
                                        size_unit_type_id: sut.id,
                                        value: value)
            else
              t.update_attributes(value: value)
            end
          end
        end
      end
    end

    redirect_to edit_organization_path(@organization, :anchor => 'tabs-abacus-sut')
  end

  def set_technology_size_unit_abacus
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:organization])
    @technologies = @organization.organization_technologies
    @size_units = SizeUnit.all

    @technologies.each do |technology|
      @size_units.each do |size_unit|
        value = params[:technology_size_units_abacus]["#{size_unit.id}"]["#{technology.id}"].to_f

        unless value.nil?
          t = TechnologySizeUnit.where( organization_id: @organization.id,
                                        organization_technology_id: technology.id,
                                        size_unit_id: size_unit.id).first

          if t.nil?
            TechnologySizeUnit.create(organization_id: @organization.id,
                                      organization_technology_id: technology.id,
                                      size_unit_id: size_unit.id,
                                      value: value)
          else
            t.update_attributes(value: value)
          end
        end
      end
    end

    redirect_to edit_organization_path(@organization, :anchor => 'tabs-abacus-tsu')

  end

  def set_abacus
    authorize! :edit_organizations, Organization

    @ot = OrganizationTechnology.find_by_id(params[:technology])
    @complexities = @ot.organization.organization_uow_complexities
    @unitofworks = @ot.unit_of_works

    @unitofworks.each do |uow|
      @complexities.each do |c|
        a = AbacusOrganization.find_or_create_by_unit_of_work_id_and_organization_uow_complexity_id_and_organization_technology_id_and_organization_id(uow.id, c.id, @ot.id, params[:id])
        begin
          a.update_attribute(:value, params['abacus']["#{uow.id}"]["#{c.id}"])
        rescue
          # :()
        end
      end
    end
    redirect_to redirect_apply(edit_organization_path(@ot.organization_id, :anchor => 'tabs-abacus-tsu'), nil, '/organizationals_params')
  end

  def set_technology_uow_synthesis
    authorize! :manage_modules_instances, ModuleProject

    #@organization = Organization.find(params[:organization])
    params[:abacus].each do |sut|
      sut.last.each do |ot|
        ot.last.each do |uow|
          uow.last.each do |cplx|
            sutc = SizeUnitTypeComplexity.where(size_unit_type_id: sut.first.to_i, organization_uow_complexity_id: cplx.first.to_i).first_or_create
            sutc.value = cplx.last
            sutc.save
          end
        end
      end
    end

    redirect_to redirect_apply(organization_module_estimation_path(@current_organization, :anchor => 'taille'), nil, '/organizationals_params')
  end

  # Update the organization's projects available inline columns
  def set_available_inline_columns
    authorize! :manage_projects_selected_columns, Organization
    redirect_to organization_setting_path(@current_organization, :anchor => 'tabs-select-columns-list')
  end

  def update_available_inline_columns
    # update selected column
    selected_columns = params['selected_inline_columns']
    query_classname = params['query_classname'].constantize
    unless selected_columns.nil?
      case params['query_classname']
        when "Project"
          @current_organization.project_selected_columns = selected_columns
        when "Organization"
          @current_organization.organization_selected_columns = selected_columns
      end
      @current_organization.save
    end

    respond_to do |format|
      format.js
      format.json { render json: selected_columns }
    end
  end

  #def import_abacus
  #  authorize! :edit_organizations, Organization
  #  @organization = Organization.find(params[:id])
  #
  #  file = params[:file]
  #
  #  case File.extname(file.original_filename)
  #    when ".ods"
  #      workbook = Roo::Spreadsheet.open(file.path, extension: :ods)
  #    when ".xls"
  #      workbook = Roo::Spreadsheet.open(file.path, extension: :xls)
  #    when ".xlsx"
  #      workbook = Roo::Spreadsheet.open(file.path, extension: :xlsx)
  #    when ".xlsm"
  #      workbook = Roo::Spreadsheet.open(file.path, extension: :xlsx)
  #  end
  #
  #  workbook.sheets.each_with_index do |worksheet, k|
  #    #if sheet name blank, we use sheetN as default name
  #    name = worksheet
  #    if name != 'ReadMe' #The ReadMe sheet is only for guidance and don't have to be proceed
  #
  #      @ot = OrganizationTechnology.find_or_create_by_name_and_alias_and_organization_id(:name => name,
  #                                                                                        :alias => name,
  #                                                                                        :organization_id => @organization.id)
  #
  #      workbook.default_sheet=workbook.sheets[k]
  #      workbook.each_with_index do |row, i|
  #        row.each_with_index do |cell, j|
  #          unless row.nil?
  #            unless workbook.cell(1,j+1) == "Abacus" or workbook.cell(i+1,1) == "Abacus"
  #              if can? :manage, Organization
  #                @ouc = OrganizationUowComplexity.find_or_create_by_name_and_organization_id(:name => workbook.cell(1,j+1), :organization_id => @organization.id)
  #              end
  #
  #              if can? :manage, Organization
  #                @uow = UnitOfWork.find_or_create_by_name_and_alias_and_organization_id(:name => workbook.cell(i+1,1), :alias => workbook.cell(i+1,1), :organization_id => @organization.id)
  #                unless @uow.organization_technologies.map(&:id).include?(@ot.id)
  #                  @uow.organization_technologies << @ot
  #                end
  #                @uow.save
  #              end
  #
  #              ao = AbacusOrganization.find_by_unit_of_work_id_and_organization_uow_complexity_id_and_organization_technology_id_and_organization_id(
  #                  @uow.id,
  #                  @ouc.id,
  #                  @ot.id,
  #                  @organization.id
  #              )
  #
  #              if ao.nil?
  #                if can? :manage, Organization
  #                  AbacusOrganization.create(
  #                      :unit_of_work_id => @uow.id,
  #                      :organization_uow_complexity_id => @ouc.id,
  #                      :organization_technology_id => @ot.id,
  #                      :organization_id => @organization.id,
  #                      :value => workbook.cell(i+1, j+1))
  #                end
  #              else
  #                ao.update_attribute(:value, workbook.cell(i+1, j+1))
  #              end
  #            end
  #          end
  #        end
  #      end
  #    end
  #  end
  #
  #  redirect_to redirect_apply(edit_organization_path(@organization.id), nil, '/organizationals_params')
  #end
  #
  #def export_abacus
  #  authorize! :edit_organizations, Organization
  #
  #  @organization = Organization.find(params[:id])
  #  p=Axlsx::Package.new
  #  wb=p.workbook
  #  @organization.organization_technologies.each_with_index do |ot|
  #    wb.add_worksheet(:name => ot.name) do |sheet|
  #      style_title = sheet.styles.add_style(:bg_color => 'B0E0E6', :sz => 14, :b => true, :alignment => {:horizontal => :center})
  #      style_title2 = sheet.styles.add_style(:sz => 14, :b => true, :alignment => {:horizontal => :center})
  #      style_title_red = sheet.styles.add_style(:bg_color => 'B0E0E6', :fg_color => 'FF0000', :sz => 14, :b => true, :i => true, :alignment => {:horizontal => :center})
  #      style_title_orange = sheet.styles.add_style(:bg_color => 'B0E0E6', :fg_color => 'FF8C00', :sz => 14, :b => true, :i => true, :alignment => {:horizontal => :center})
  #      style_title_right = sheet.styles.add_style(:bg_color => 'E6E6E6', :sz => 14, :b => true, :alignment => {:horizontal => :right})
  #      style_title_right_red = sheet.styles.add_style(:bg_color => 'E6E6E6', :fg_color => 'FF8C00', :sz => 14, :b => true, :i => true, :alignment => {:horizontal => :right})
  #      style_title_right_orange = sheet.styles.add_style(:bg_color => 'E6E6E6', :fg_color => 'FF8C00', :sz => 14, :b => true, :i => true, :alignment => {:horizontal => :right})
  #      style_data = sheet.styles.add_style(:sz => 12, :alignment => {:horizontal => :center}, :locked => false)
  #      style_date = sheet.styles.add_style(:format_code => 'YYYY-MM-DD HH:MM:SS')
  #      head = ['Abacus']
  #      head_style = [style_title2]
  #      @organization.organization_uow_complexities.each_with_index do |comp|
  #        head.push(comp.name)
  #        if comp.state == 'retired'
  #          head_style.push(style_title_red)
  #        elsif comp.state == 'draft'
  #          head_style.push(style_title_orange)
  #        else
  #          head_style.push(style_title)
  #        end
  #      end
  #      row=sheet.add_row(head, :style => head_style)
  #      ot.unit_of_works.each_with_index do |uow|
  #        uow_row = []
  #        if uow.state == 'retired'
  #          uow_row_style=[style_title_right_red]
  #        elsif uow.state == 'draft'
  #          uow_row_style=[style_title_right_orange]
  #        else
  #          uow_row_style=[style_title_right]
  #        end
  #        uow_row = [uow.name]
  #
  #        @organization.organization_uow_complexities.each_with_index do |comp2, i|
  #          if AbacusOrganization.where(:unit_of_work_id => uow.id, :organization_uow_complexity_id => comp2.id, :organization_technology_id => ot.id, :organization_id => @organization.id).first.nil?
  #            data = ''
  #          else
  #            data = AbacusOrganization.where(:unit_of_work_id => uow.id,
  #                                            :organization_uow_complexity_id => comp2.id,
  #                                            :organization_technology_id => ot.id, :organization_id => @organization.id).first.value
  #          end
  #          uow_row_style.push(style_data)
  #          uow_row.push(data)
  #        end
  #        row=sheet.add_row(uow_row, :style => uow_row_style)
  #      end
  #      sheet.sheet_protection.delete_rows = true
  #      sheet.sheet_protection.delete_columns = true
  #      sheet.sheet_protection.format_cells = true
  #      sheet.sheet_protection.insert_columns = false
  #      sheet.sheet_protection.insert_rows = false
  #      sheet.sheet_protection.select_locked_cells = false
  #      sheet.sheet_protection.select_unlocked_cells = false
  #      sheet.sheet_protection.objects = false
  #      sheet.sheet_protection.sheet = true
  #    end
  #  end
  #  wb.add_worksheet(:name => 'ReadMe') do |sheet|
  #    style_title2 = sheet.styles.add_style(:sz => 14, :b => true, :alignment => {:horizontal => :center})
  #    style_title_right = sheet.styles.add_style(:bg_color => 'E6E6E6', :sz => 13, :b => true, :alignment => {:horizontal => :right})
  #    style_date = sheet.styles.add_style(:format_code => 'YYYY-MM-DD HH:MM:SS', :alignment => {:horizontal => :left})
  #    style_text = sheet.styles.add_style(:alignment => {:wrapText => :true})
  #    style_field = sheet.styles.add_style(:bg_color => 'F5F5F5', :sz => 12, :b => true)
  #
  #    sheet.add_row(['This File is an export of a ProjEstimate abacus'], :style => style_title2)
  #    sheet.merge_cells 'A1:F1'
  #    sheet.add_row(['Organization: ', "#{@organization.name} (#{@organization.id})", @organization.description], :style => [style_title_right, 0, style_text])
  #    sheet.add_row(['Date: ', Time.now], :style => [style_title_right, style_date])
  #    sheet.add_row([' '])
  #    sheet.merge_cells 'A5:F5'
  #    sheet.add_row(['There is one sheet by technology. Each sheet is organized with the complexity by column and the Unit Of work by row.'])
  #    sheet.merge_cells 'A6:F6'
  #    sheet.add_row(['For the complexity and the Unit Of Work state, we are using the following color code : Red=Retired, Orange=Draft).'])
  #    sheet.merge_cells 'A7:F7'
  #    sheet.add_row(['In order to allow this abacus to be re-imported into ProjEstimate and to prevent users from accidentally changing the structure of the sheets, workbooks have been protected.'])
  #    sheet.merge_cells 'A8:F8'
  #    sheet.add_row(['Advanced users can remove the protection (there is no password). For further information you can have a look on the ProjEstimate Help.'])
  #    row=sheet.add_row(['For ProjEstimate Help, Click to go'])
  #    sheet.add_hyperlink :location => 'http://forge.estimancy.com/projects/pe/wiki/Organizations', :ref => "A#{row.index+1}"
  #    sheet.add_row([' '])
  #    sheet.add_row([' '])
  #    sheet.add_row(['Technologies'], :style => [style_title_right])
  #    sheet.add_row(['Alias', 'Name', 'Description', 'State', 'Productivity Ratio'], :style => style_field)
  #    @organization.organization_technologies.each_with_index do |ot|
  #      sheet.add_row([ot.alias, ot.name, ot.description, ot.state, ot.productivity_ratio], :style => [0, 0, style_text])
  #    end
  #    sheet.add_row([' '])
  #    sheet.add_row(['Complexities'], :style => [style_title_right])
  #    sheet.add_row(['Display Order', 'Name', 'Description', 'State'], :style => style_field)
  #    @organization.organization_uow_complexities.each_with_index do |comp|
  #      sheet.add_row([comp.display_order, comp.name, comp.description, comp.state], :style => [0, 0, style_text])
  #    end
  #    sheet.add_row([' '])
  #    sheet.add_row(['Units OF Works'], :style => [style_title_right])
  #    sheet.add_row(['Alias', 'Name', 'Description', 'State'], :style => style_field)
  #    @organization.unit_of_works.each_with_index do |uow|
  #      sheet.add_row([uow.alias, uow.name, uow.description, uow.state], :style => [0, 0, style_text])
  #    end
  #    sheet.column_widths 20, 32, 80, 10, 18
  #  end
  #  send_data p.to_stream.read, :filename => @organization.name+'.xlsx'
  #end


  # Duplicate the organization
  # Function de delete after => is replaced by the create_from_image fucntion
  def duplicate_organization
    authorize! :manage_master_data, :all

    original_organization = Organization.find(params[:organization_id])
    new_organization = original_organization.amoeba_dup
    if new_organization.save
      original_organization.save #Original organization copy number will be incremented to 1
      flash[:notice] = I18n.t(:organization_successfully_copied)
    else
      flash[:error] = "#{ I18n.t(:errors_when_copying_organization)} : #{new_organization.errors.full_messages.join(', ')}"
    end
    redirect_to organizationals_params_path
  end

  def show
    authorize! :show_organizations, Organization
  end

  private
  def check_if_organization_is_image(organization)
    if organization.is_image_organization == true
      redirect_to("/organizationals_params", flash: { error: "Vous ne pouvez pas accéder aux estimations d'une organization image"}) and return
    end
  end


end
