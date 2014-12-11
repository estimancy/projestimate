#encoding: utf-8
############################################################################
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

class FactorsController < ApplicationController
  load_and_authorize_resource :except => [:index]

  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  def index
    @factors = Factor.order("factor_type")
  end

  def show
    @factor = Factor.find(params[:id])
  end

  # GET /factors/new
  # GET /factors/new.json
  def new
    @factor = Factor.new
  end

  # GET /factors/1/edit
  def edit
    @factor = Factor.find(params[:id])
  end

  # POST /factors
  # POST /factors.json
  def create
    @factor = Factor.new(params[:factor])

    respond_to do |format|
      if @factor.save
        format.html { redirect_to factors_path, notice: 'Factor was successfully created.' }
        format.json { render json: "/organizationals_params", status: :created, location: @factor }
      else
        format.html { render action: "new" }
        format.json { render json: @factor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /factors/1
  # PUT /factors/1.json
  def update
    @factor = Factor.find(params[:id])

    respond_to do |format|
      if @factor.update_attributes(params[:factor])
        format.html { redirect_to factors_path, notice: 'Factor was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @factor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /factors/1
  # DELETE /factors/1.json
  def destroy
    @factor = Factor.find(params[:id])
    @factor.destroy

    respond_to do |format|
      format.html { redirect_to factors_path }
      format.json { head :no_content }
    end
  end
end
