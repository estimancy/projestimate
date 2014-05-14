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

class VersionsController < ApplicationController
  load_and_authorize_resource
  # GET /versions
  # GET /versions.json
  def index
    @versions = Version.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @versions }
    end
  end

  # GET /versions/1
  # GET /versions/1.json
  def show
    @version = Version.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @version }
    end
  end

  # GET /versions/new
  # GET /versions/new.json
  def new
    @version = Version.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @version }
    end
  end

  # GET /versions/1/edit
  def edit
    @version = Version.find(params[:id])
  end

  # POST /versions
  # POST /versions.json
  def create
    @version = Version.new(params[:version])

    respond_to do |format|
      if @version.save
        format.html { redirect_to @version, notice: "#{I18n.t (:notice_version_successful_created)}"}
        format.json { render json: @version, status: :created, location: @version }
      else
        format.html { render action: 'new' }
        format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /versions/1
  # PUT /versions/1.json
  def update
    @version = Version.find(params[:id])

    respond_to do |format|
      if @version.update_attributes(params[:version])
        format.html { redirect_to @version, notice: "#{I18n.t (:notice_version_successful_updated)}"}
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /versions/1
  # DELETE /versions/1.json
  def destroy
    @version = Version.find(params[:id])
    @version.destroy

    respond_to do |format|
      format.html { redirect_to versions_url }
      format.json { head :no_content }
    end
  end
end
