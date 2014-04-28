#########################################################################
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
########################################################################

class OrganizationTechnologiesController < ApplicationController
  load_resource

  def index
    #No authorize required since everyone can edit

    @organization = Organization.find(params[:id])
    @organization_technologies = @organization.organization_technologies
  end

  def edit
    #No authorize required since everyone can edit

    @organization_technology = OrganizationTechnology.find(params[:id])
    @organization = @organization_technology.organization

  end

  def new
    authorize! :edit_organizations, Organization

    @organization_technology = OrganizationTechnology.new
    @organization = Organization.find_by_id(params[:organization_id])
  end

  def create
    authorize! :edit_organizations, Organization

    @organization_technology = OrganizationTechnology.new(params[:organization_technology])
    @organization = Organization.find_by_id(params['organization_technology']['organization_id'])

    if @organization_technology.save
      flash[:notice] = I18n.t (:notice_organization_technology_successful_created)
      redirect_to redirect_apply(nil, new_organization_technology_path(params[:organization_technology]), edit_organization_path(@organization, :anchor => 'tabs-4'))
    else
      render action: 'new', :organization_id => @organization.id
    end
  end

  def update
    authorize! :edit_organizations, Organization

    @organization_technology = OrganizationTechnology.find(params[:id])
    @organization = @organization_technology.organization

    if @organization_technology.update_attributes(params[:organization_technology])
      flash[:notice] = I18n.t (:notice_organization_technology_successful_updated)
      redirect_to redirect_apply(edit_organization_technology_path(params[:organization_technology]), nil, edit_organization_path(@organization, :anchor => 'tabs-4'))
    else
      render action: 'edit', :organization_id => @organization.id
    end
  end

  def destroy
    authorize! :manage, Organization
    @organization_technology = OrganizationTechnology.find(params[:id])
    organization_id = @organization_technology.organization_id
    @organization_technology.delete
    respond_to do |format|
      format.html { redirect_to redirect(edit_organization_path(organization_id, :anchor => 'tabs-4')), notice: "#{I18n.t (:notice_organization_technology_successful_deleted)}" }
    end
  end

  def set_technology_uos_syntesis
    authorize! :edit_organizations, Organization

    @organization = Organization.find(params[:organization])
    @technologies = OrganizationTechnology.where(id: params[:technology_uos_synthesis].keys)
    @unitofworks = @organization.unit_of_works

    array = []
    @technologies.each do |technology|

      array << technology.id

      unit = UnitOfWork.find(params[:technology_uos_synthesis]["#{technology.id}".to_sym].keys.first)
      unit.organization_technology_ids = array
      unit.save
    end

    redirect_to redirect_apply(edit_organization_path(@organization, :anchor => 'tabs-9'), nil, '/organizationals_params')
  end

  #def change_abacus
  #  authorize! :edit_organizations, Organization
  #  @ot = OrganizationTechnology.find(params[:technology])
  #  @organization = @ot.organization
  #  @unitofworks = @ot.unit_of_works
  #  @complexities = @ot.organization.organization_uow_complexities
  #end
end
