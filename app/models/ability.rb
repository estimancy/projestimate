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

#Ability for role management. See CanCan on github fore more information about Role.
class Ability
  include CanCan::Ability

  #Initialize Ability then load permissions
  def initialize(user, organization)

    #Uncomment in order to authorize everybody to manage all the app
    if Rails.env == "test" || user.super_admin == true
      can :manage, :all
    end

    #Only the super-admin has the rights to manage the master-data
    if user.super_admin?
      can :manage_master_data, :all
    end

    #cannot :update, [Language, PeAttribute, Currency, AdminSetting, AuthMethod, Permission], :record_status => {:name => 'Retired'}

    #For organization and estimations permissions
    alias_action :show_estimations_permissions, :to => :manage_estimations_permissions
    alias_action :manage_estimations_permissions, :show_organization_permissions, :to => :manage_organization_permissions

    # For projects selected columns
    alias_action :show_projects_selected_columns, :to => :manage_projects_selected_columns

    # Add Action Aliases, for example:  alias_action :edit, :to => :update
    # Notice the edit action is aliased to update. This means if the user is able to update a record he also has permission to edit it.
    alias_action [:show_groups, Group], :to => [:manage, Group]

    #For organization
    alias_action :show_organizations, :to => :edit_organizations
    alias_action :edit_organizations, :to => :create_organizations

    # For estimation: when we can edit a project, we can also see and show it
    alias_action :see_project, :to => :show_project
    alias_action :show_project, :to => :edit_project
    alias_action :alter_project_areas, :alter_acquisition_categories, :alter_platform_categories, :alter_project_categories, :to => :edit_project
    alias_action :execute_estimation_plan, :manage_estimation_widgets, :alter_estimation_status, :alter_project_status_comment, :commit_project, :to => :alter_estimation_plan
    alias_action :alter_estimation_plan, :manage_project_security, :to => :edit_project


    #When user can create a project template, he also can create a project from scratch
    #alias_action :create_project_from_scratch, :create_project_from_template, :show_estimation_models, :to => :manage_estimation_models
    alias_action :edit_project, :to => :manage_estimation_models

    #For instance modules
    alias_action :show_modules_instances, :to => :manage_modules_instances

    #Load user groups permissions
    if user && !user.groups.where(organization_id: organization.id).empty?
      permissions_array = []

      user.groups.where(organization_id: organization.id).map do |grp|
        grp.permissions.map do |i|
          if i.object_associated.blank?
            permissions_array << [i.alias.to_sym, :all]
          else
            permissions_array << [i.alias.to_sym, i.object_associated.constantize]
          end
        end
      end

      for perm in permissions_array
        unless perm[0].nil? or perm[1].nil?
          can perm[0], perm[1]
        end
      end

      #@array_users = Hash.new {|h,k| h[k]=[]}
      #@array_status_groups = Hash.new {|h,k| h[k]=[]}
      #@array_groups = Hash.new {|h,k| h[k]=[]}

      @array_users = Array.new
      @array_status_groups = Array.new
      @array_groups = Array.new

      #Specfic project security loading
      prj_scrts = ProjectSecurity.find_all_by_user_id(user.id)
      unless prj_scrts.empty?
        specific_permissions_array = []
        prj_scrts.each do |prj_scrt|
          unless prj_scrt.project_security_level.nil?
            prj_scrt.project.organization.estimation_statuses.each do |es|
              prj_scrt.project_security_level.permissions.select{|i| i.is_permission_project }.map do |permission|
                @array_users << [permission.id, prj_scrt.project.id, es.id]
              end
            end
          end
        end
      end

      user.groups.each do |grp|
        prj_scrts = ProjectSecurity.find_all_by_group_id(grp.id)
        unless prj_scrts.empty?
          specific_permissions_array = []
          prj_scrts.each do |prj_scrt|
            # Get the project/estimation permissions
            unless prj_scrt.project_security_level.nil?
              prj_scrt.project.organization.estimation_statuses.each do |es|
                prj_scrt.project_security_level.permissions.select{|i| i.is_permission_project }.map do |permission|
                  @array_groups << [permission.id, prj_scrt.project.id, es.id]
                end
              end
            end
          end
        end

        grp.estimation_status_group_roles.each do |esgr|
          esgr_security_level = esgr.project_security_level
          unless esgr_security_level.nil?
            esgr_security_level.permissions.select{|i| i.is_permission_project }.map do |permission|
              esgr.organization.projects.each do |project|
                @array_status_groups << [permission.id, project.id, esgr.estimation_status.id]
              end
            end
          end
        end
      end

      global = @array_users + @array_groups
      status = @array_status_groups

      [status, global].inject(:&).each do |a|
        permission = Permission.find(a[0]).alias
        project = Project.find(a[1])
        status = EstimationStatus.find(a[2])

        unless project.nil?
          unless project.is_model == true && (permission.start_with?("alter") || permission.include?("widget"))
            can permission.to_sym, project, estimation_status_id: status.id
          end
        end
      end
    end
  end
end



