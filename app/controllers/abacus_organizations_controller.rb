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

class AbacusOrganizationsController < ApplicationController
  load_resource

  # GET /abacus_organizations
  # GET /abacus_organizations.json
  def index
    #No authorize required since everyone can edit
    @abacus_organizations = AbacusOrganization.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @abacus_organizations }
    end
  end

  # GET /abacus_organizations/1
  # GET /abacus_organizations/1.json
  def show
    #No authorize required since everyone can edit
    @abacus_organization = AbacusOrganization.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @abacus_organization }
    end
  end

  # GET /abacus_organizations/new
  # GET /abacus_organizations/new.json
  def new
    authorize! :edit_organizations, Organization
    @abacus_organization = AbacusOrganization.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @abacus_organization }
    end
  end

  # GET /abacus_organizations/1/edit
  def edit
    #No authorize required since everyone can edit
    @abacus_organization = AbacusOrganization.find(params[:id])
  end

  # POST /abacus_organizations
  # POST /abacus_organizations.json
  def create
    authorize! :edit_organizations, Organization
    @abacus_organization = AbacusOrganization.new(params[:abacus_organization])

    respond_to do |format|
      if @abacus_organization.save
        format.html { redirect_to @abacus_organization, notice: 'Abacus organization was successfully created.' }
        format.json { render json: @abacus_organization, status: :created, location: @abacus_organization }
      else
        format.html { render action: 'new' }
        format.json { render json: @abacus_organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /abacus_organizations/1
  # PUT /abacus_organizations/1.json
  def update
    authorize! :edit_organizations, Organization
    @abacus_organization = AbacusOrganization.find(params[:id])

    respond_to do |format|
      if @abacus_organization.update_attributes(params[:abacus_organization])
        format.html { redirect_to @abacus_organization, notice: 'Abacus organization was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @abacus_organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /abacus_organizations/1
  # DELETE /abacus_organizations/1.json
  def destroy
    authorize! :edit_organizations, Organization
    @abacus_organization = AbacusOrganization.find(params[:id])
    @abacus_organization.destroy

    respond_to do |format|
      format.html { redirect_to abacus_organizations_url }
      format.json { head :no_content }
    end
  end
end
