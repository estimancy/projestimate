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

class WorkElementTypesController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  def index
    authorize! :manage_wet, WorkElementType
    set_page_title "Work Element Type"
    @work_element_types = WorkElementType.all
  end

  def new
    authorize! :manage_wet, WorkElementType
    set_page_title "Work Element Type"
    @work_element_type = WorkElementType.new
    @peicons = Peicon.all
  end

  # GET /work_element_types/1/edit
  def edit
    authorize! :manage_wet, WorkElementType
    set_page_title "Work Element Type"
    @work_element_type = WorkElementType.find(params[:id])
    @peicons = Peicon.all
  end

  def create
    authorize! :manage_wet, WorkElementType
    current_work_element_type = WorkElementType.new(params[:work_element_type])
    @work_element_type = current_work_element_type.dup

    @work_element_type.peicon_id = Peicon.find_by_name("Default").id

    if @work_element_type.save
      redirect_to redirect(work_element_types_path)
    else
      render action: "new"
    end
  end

  def update
    authorize! :manage_wet, WorkElementType
    @work_element_type = WorkElementType.find(params[:id])

    if @work_element_type.update_attributes(params[:work_element_type])
      flash[:notice] =  'Work element type was successfully updated.'
      redirect_to redirect(work_element_types_path)
    else
      render action: "edit"
    end
  end

  def destroy
    authorize! :manage_wet, WorkElementType
    @work_element_type = WorkElementType.find(params[:id])
    #logical deletion: delete don't have to suppress records anymore
    @work_element_type.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)

    redirect_to work_element_types_url
  end
end
