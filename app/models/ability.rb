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

    ##Uncomment in order to authorize everybody to manage all the app
    #if user.super_admin == true
      can :manage, :all
    #end
    #
    #can :edit, Project
    #can :update, Project
    #cannot :update, [WbsActivityElement, WbsActivity, Language, PeAttribute, ProjectArea,
    #                 ProjectCategory, PlatformCategory, AcquisitionCategory, Peicon,
    #                 WorkElementType, Currency, AdminSetting, AuthMethod, Group, LaborCategory, ProjectSecurityLevel,
    #                 Permission], :record_status => {:name => 'Retired'}
    #
    ##Load user groups permissions
    #if user && !user.groups.empty?
    #  permissions_array = []
    #  user.group_for_global_permissions.map do |grp|
    #    grp.permissions.map do |i|
    #      if i.object_associated.blank?
    #        permissions_array << [i.alias.to_sym, :all]
    #      else
    #        permissions_array << [i.alias.to_sym, i.object_associated.constantize]
    #      end
    #    end
    #  end
    #
    #  for perm in permissions_array
    #    unless perm[0].nil? or perm[1].nil?
    #      can perm[0], perm[1]
    #    end
    #  end
    #
    #  #Specfic project security loading
    #  prj_scrts = ProjectSecurity.find_all_by_user_id(user.id)
    #
    #  unless prj_scrts.empty?
    #    specific_permissions_array = []
    #    prj_scrts.each do |prj_scrt|
    #      prj_scrt.project_security_level.permissions.select{|i| i.is_permission_project }.map do |i|
    #        can i.alias.to_sym, prj_scrt.project
    #      end
    #    end
    #  end
    #
    #  user.group_for_project_securities.each do |grp|
    #    prj_scrts = ProjectSecurity.find_all_by_group_id(grp.id)
    #    unless prj_scrts.empty?
    #      specific_permissions_array = []
    #      prj_scrts.each do |prj_scrt|
    #        prj_scrt.project_security_level.permissions.select{|i| i.is_permission_project }.map do |i|
    #          can i.alias.to_sym, prj_scrt.project
    #        end
    #      end
    #    end
    #  end

    #end
  end
end



