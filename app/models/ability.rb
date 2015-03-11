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
  def initialize(user)

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
    alias_action :show_estimation_models, :to => :manage_estimation_models

    #For instance modules
    alias_action :show_modules_instances, :to => :manage_modules_instances

    #Load user groups permissions
    if user && !user.groups.empty?
      permissions_array = []

      #user.group_for_global_permissions.map do |grp|   # Only the groups for global_permissions will take on account
      user.groups.map do |grp|                          # All the groups will take on account
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

      #Specfic project security loading
      prj_scrts = ProjectSecurity.find_all_by_user_id(user.id)
      unless prj_scrts.empty?
        specific_permissions_array = []
        prj_scrts.each do |prj_scrt|
          unless prj_scrt.project_security_level.nil?
            prj_scrt.project_security_level.permissions.select{|i| i.is_permission_project }.map do |i|
              can i.alias.to_sym, prj_scrt.project
            end
          end
        end
      end

      ###user.group_for_project_securities.each do |grp|       # Only the groups for project_securities will take on account
      user.groups.each do |grp|       # Only the groups will take on account
        prj_scrts = ProjectSecurity.find_all_by_group_id(grp.id)
        unless prj_scrts.empty?
          specific_permissions_array = []
          prj_scrts.each do |prj_scrt|
            # Get the project/estimation permissions
            unless prj_scrt.project_security_level.nil?
              prj_scrt.project_security_level.permissions.select{|i| i.is_permission_project }.map do |i|
                if prj_scrt.project.is_model
                  #For template/model, only the model's permissions will be taken in account
                  if prj_scrt.is_model_permission
                    can i.alias.to_sym, prj_scrt.project
                  end
                else
                  can i.alias.to_sym, prj_scrt.project
                end
              end
            end
          end
        end
      end

      user.groups.each do |grp|
        grp.estimation_status_group_roles.each do |esgr|
          esgr.project_security_level.permissions.select{|i| i.is_permission_project }.map do |permission|
            esgr.organization.projects.each do |project|
              #if project.is_model
                #For template/model, only the model's permissions will be taken in account
                #if esgr.is_model_permission
                #  can i.alias.to_sym, project
                #end
              #else
                can permission.alias.to_sym, project, estimation_status_id: esgr.estimation_status_id
              #end
            end
          end
        end
      end
    end
  end
end



