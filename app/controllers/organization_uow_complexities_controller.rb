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

class OrganizationUowComplexitiesController < ApplicationController

  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  load_resource

  def index
    #No authorize required since everyone can edit

    @organization = Organization.find(params[:id])
    @organization_uow_complexities = @organization.organization_uow_complexities
  end

  def edit
    #No authorize required since everyone can edit
    @organization_uow_complexity = OrganizationUowComplexity.find(params[:id])
    @organization = @organization_uow_complexity.organization
  end

  def new
    authorize! :edit_organizations, Organization
    @organization = Organization.find_by_id(params[:organization_id])
    @organization_uow_complexity = OrganizationUowComplexity.new
  end

  def create
    authorize! :edit_organizations, Organization
    @organization_uow_complexity = OrganizationUowComplexity.new(params[:organization_uow_complexity])
    @organization = Organization.find_by_id(params[:organization_uow_complexity][:organization_id])

    if params[:organization_uow_complexity][:organization_id].present?
      @organization = Organization.find_by_id(params[:organization_uow_complexity][:organization_id])
      @organization_uow_complexity.organization_id = @organization.id
    end

    if @organization_uow_complexity.save
      flash[:notice] = I18n.t(:notice_organization_uow_complexity_successful_created)

      redirect_to redirect_apply(nil, new_organization_uow_complexity_path(params[:organization_uow_complexity]), edit_organization_path(params[:organization_uow_complexity][:organization_id], :anchor => 'tabs-5'))
    else
      render action: 'new', :organization_id => @organization
    end

  end

  def update
    authorize! :edit_organizations, Organization

    @organization_uow_complexity = OrganizationUowComplexity.find(params[:id])
    @organization = @organization_uow_complexity.organization

    if params[:organization_uow_complexity][:organization_id].present?
      @organization = Organization.find_by_id(params[:organization_uow_complexity][:organization_id])
      @organization_uow_complexity.organization_id = @organization.id
    end

    if @organization_uow_complexity.update_attributes(params[:organization_uow_complexity])
      flash[:notice] = I18n.t (:notice_organization_uow_complexity_successful_updated)
      redirect_to redirect_apply(edit_organization_uow_complexity_path(@organization_uow_complexity.id), nil, "/organizationals_params")
    else
      render action: 'edit', :organization_id => @organization.id
    end

  end

  def set_default
    cplx = OrganizationUowComplexity.find(params[:id])

    cplx.factor.organization_uow_complexities.each do |o|
      o.is_default = false
      o.save(validate: false)
    end

    cplx.is_default = true
    cplx.save(validate: false)

    redirect_to edit_organization_path(cplx.organization, anchor: "tabs-7")
  end

  def destroy
    authorize! :manage, Organization
    @organization_uow_complexity = OrganizationUowComplexity.find(params[:id])
    organization = @organization_uow_complexity.organization

    @organization_uow_complexity.delete
    begin
      redirect_to redirect(edit_organization_path(organization, anchor: "tabs-7")), notice: "#{I18n.t (:notice_organization_uow_complexity_successful_deleted)}"
    rescue
      redirect_to "/organizationals_params"
    end
  end
end
