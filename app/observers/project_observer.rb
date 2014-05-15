#encoding: utf-8
#############################################################################
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

class ProjectObserver < ActiveRecord::Observer
  observe Project

  #def after_create(project)
  #New default wbs
  #pe_wbs_project = PeWbsProject.new(:project => project)
  #pe_wbs_project.save

  #New root pbs_project_element
  #pbs_project_element = PbsProjectElement.new(:is_root => true, :pe_wbs_project_id => pe_wbs_project.id, :work_element_type_id => default_work_element_type.id, :position => 0, :name => "Root folder")
  #pbs_project_element.save
  #end

  #def before_destroy(project)
  #project.users.each do |user|
  #  user.ten_latest_projects.delete(project.id)
  #  user.save
  #end
  #end

  #private
  #def default_work_element_type
  #  wet = WorkElementType.find_by_alias("folder")
  #  return wet
  #end

end