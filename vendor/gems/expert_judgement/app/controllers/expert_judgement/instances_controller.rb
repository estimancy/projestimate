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

class ExpertJudgement::InstancesController < ApplicationController

  def index
    ExpertJudgement::Instance.all
  end

  def show
    @instance = ExpertJudgement::Instance.find(params[:id])
  end

  def new
    @instance = ExpertJudgement::Instance.new
  end

  def edit
    @instance = ExpertJudgement::Instance.find(params[:id])
  end

  def create
    @instance = ExpertJudegement::Instance.new(params[:instance])
    @instance.organization_id = params[:instance][:organization_id].to_i
    @instance.save
    redirect_to main_app.edit_organization_path(@instance.organization_id)
  end

  def update
    @instance = ExpertJudgement::Instance.find(params[:id])
    @instance.update_attributes(params[:instance])
    redirect_to main_app.edit_organization_path(@instance.organization_id)
  end

  def destroy
    @instance = ExpertJudgement::Instance.find(params[:id])
    organization_id = @instance.organization_id
    @instance.delete
    redirect_to main_app.edit_organization_path(organization_id)
  end

end
