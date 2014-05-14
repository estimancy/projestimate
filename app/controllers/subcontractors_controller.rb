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

class SubcontractorsController < ApplicationController
  load_resource

  def new
    authorize! :edit_organizations, Organization
    @subcontractor = Subcontractor.new
    @organization = Organization.find_by_id(params[:organization_id])
  end

  def edit
    #No authorize required since everyone can edit
    @subcontractor = Subcontractor.find(params[:id])
    @organization = @subcontractor.organization

    @default_subcontractors = @organization.subcontractors.where('alias IN (?)', %w(undefined internal subcontracted))
    if @subcontractor.alias.in?(%w(undefined internal subcontracted))
      flash[:error] = "#{@subcontractor.name} subcontractor can't be modified"
      redirect_to edit_organization_path(@organization, :anchor => 'tabs-7')
    end

  end

  def create
    authorize! :edit_organizations, Organization
    set_page_title 'Subcontractors'
    @subcontractor = Subcontractor.new(params[:subcontractor])
    @organization = Organization.find_by_id(params['subcontractor']['organization_id'])

    if @subcontractor.save
      flash[:notice] = I18n.t(:notice_subcontractor_successfully_created)
      redirect_to edit_organization_path(@organization, :anchor => 'tabs-7')
    else
      render action: 'new', :organization_id => @organization.id
    end
  end

  def update
    authorize! :edit_organizations, Organization
    @subcontractor = Subcontractor.find(params[:id])
    @organization = @subcontractor.organization

    if @subcontractor.update_attributes(params[:subcontractor])
      flash[:notice] = I18n.t(:notice_subcontractor_successfully_updated)
      redirect_to (edit_organization_path(@organization, :anchor => 'tabs-7'))
    else
      render action: 'edit', :organization_id => @organization.id
    end
  end

  def destroy
    authorize! :manage, Organization
    @subcontractor = Subcontractor.find(params[:id])
    organization_id = @subcontractor.organization_id
    @subcontractor.destroy
    flash[:notice] = I18n.t(:notice_subcontractor_successfully_deleted)
    redirect_to edit_organization_path(organization_id, :anchor => 'tabs-7')
  end
end
