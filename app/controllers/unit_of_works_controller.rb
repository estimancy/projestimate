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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################
#
class UnitOfWorksController < ApplicationController

  load_and_authorize_resource :except => [:index]

  def index
    #No authorize required since everyone can edit

    @organization = Organization.find(params[:id])
    @organization_uow_complexities = @organization.unit_of_works
  end

  def edit
    #No authorize required since everyone can edit
    @unit_of_work = UnitOfWork.find(params[:id])
    @organization = @unit_of_work.organization
  end

  def new
    authorize! :edit_organizations, Organization
    @unit_of_work = UnitOfWork.new
    @organization = Organization.find_by_id(params[:organization_id])
  end

  def create
    authorize! :edit_organizations, Organization
    @unit_of_work = UnitOfWork.new(params[:unit_of_work])
    @organization = Organization.find_by_id(params[:unit_of_work][:organization_id])

    if @unit_of_work.save
      flash[:notice] = I18n.t(:notice_unit_of_work_successful_created)
      redirect_to redirect_apply(nil,
                                 new_unit_of_work_path(params[:unit_of_work]),
                                 edit_organization_path(params[:unit_of_work][:organization_id], :anchor => 'tabs-6'))
    else
      render action: 'new', :organization_id => @organization.id
    end
  end

  def update
    authorize! :edit_organizations, Organization
    @unit_of_work = UnitOfWork.find(params[:id])
    @organization = Organization.find_by_id(params[:unit_of_work][:organization_id])
    if @unit_of_work.update_attributes(params[:unit_of_work])
      flash[:notice] = I18n.t (:notice_unit_of_work_successful_updated)
      redirect_to redirect_apply(edit_unit_of_work_path(@unit_of_work),
                                 nil,
                                 edit_organization_path(params[:unit_of_work][:organization_id],
                                                        :anchor => 'tabs-6'))
    else
      render action: 'edit', :organization_id => @organization.id
    end
  end

  def destroy
    authorize! :manage, Organization
    @unit_of_work = UnitOfWork.find(params[:id])
    organization_id = @unit_of_work.organization_id
    @unit_of_work.delete
    respond_to do |format|
      format.html { redirect_to redirect(edit_organization_path(organization_id, :anchor => 'tabs-6')), notice: "#{I18n.t (:notice_unit_of_work_successful_deleted)}" }
    end
  end
end
