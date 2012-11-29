#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012 Spirula (http://www.spirula.fr)
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
########################################################################

class ModuleProjectsController < ApplicationController

  def index
    @module_projects = ModuleProject.all
  end

  def edit
    @module_project = ModuleProject.find(params[:id])
    @project = @module_project.project

    set_page_title "Editing #{@module_project.pemodule.title}"
  end

  def create
    @module_project = ModuleProject.new(params[:module_project])

    if @module_project.save
      redirect_to redirect(@module_project), notice: 'Module project was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @module_project = ModuleProject.find(params[:id])
    maps = params["module_project_attributes"]

    unless maps.nil?
      maps.keys.each do |k|
        a = ModuleProjectAttribute.find(k)
        ModuleProjectAttribute.where(:attribute_id => a.attribute_id, :module_project_id => @module_project.id).each do |mpa|
          mpa.links << ModuleProjectAttribute.find(maps[k].keys.first)
          mpa.save
        end
      end
    end

    ModuleProjectAttribute.where(:module_project_id => @module_project.id, :undefined_attribute => true).delete_all

    if @module_project.pemodule.is_typed?
      @module_project.nb_input_attr.to_i.times do
        ModuleProjectAttribute.create(:attribute_id => nil,
                                      :in_out => "input",
                                      :module_project_id => @module_project.id,
                                      :custom_attribute => "user",
                                      :is_mandatory => true,
                                      :description => "Undefined",
                                      :undefined_attribute => true,
                                      :dimensions => 3)
      end
    end

    @module_project.module_project_attributes.each_with_index do |mpa, i|
      if mpa.custom_attribute == true
        mpa.update_attribute("is_mandatory", params[:is_mandatory][i])
        mpa.update_attribute("in_out", params[:in_out][i])
        mpa.update_attribute("description", params[:description][i])
      end
    end

    redirect_to redirect(edit_module_project_path(@module_project)), notice: 'Module project was successfully updated.'
  end

  def destroy
    @module_project = ModuleProject.find(params[:id])
    @project = @module_project.project

    #re-set positions
    @array_module_positions = ModuleProject.where(:project_id => @project.id).order(:position_y).all.map(&:position_y).uniq.max || 1

    #...finally, destroy object module_project
    @module_project.destroy
    respond_to do |format|
      format.js { render :partial => "pemodules/refresh" }
    end
  end
end
