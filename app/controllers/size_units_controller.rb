# encoding: UTF-8
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

class SizeUnitsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  load_and_authorize_resource :except => [:index]

  def show
    @size_unit = SizeUnit.find(params[:id])
  end

  def new
    @size_unit = SizeUnit.new
    set_breadcrumbs "Organizations" => "/organizationals_params"
  end

  def edit
    @size_unit = SizeUnit.find(params[:id])
    set_breadcrumbs "Organizations" => "/organizationals_params", @size_unit.name => edit_size_unit_path(@size_unit)
  end

  def create
    @size_unit = SizeUnit.new(params[:size_unit])

    if @size_unit.save
      Organization.all.each do |o|
        OrganizationTechnology.all.each do |ot|
          SizeUnitType.all.each do |sut|
            TechnologySizeType.create(organization_id: o.id, organization_technology_id: ot.id, size_unit_id: @size_unit.id, size_unit_type_id: sut.id, value: 1)
          end
        end
      end
      redirect_to "/organizational_params"
    end
  end

  def update
    @size_unit = SizeUnit.find(params[:id])

    respond_to do |format|
      if @size_unit.update_attributes(params[:size_unit])
        format.html { redirect_to "/organizational_params", notice: 'Size unit was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @size_unit = SizeUnit.find(params[:id])
    @size_unit.destroy
    redirect_to "/organizational_params"
  end
end
