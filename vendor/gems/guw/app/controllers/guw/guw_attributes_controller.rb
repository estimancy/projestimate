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


class Guw::GuwAttributesController < ApplicationController
  def index
    @guw_attributes = Guw::GuwModel.find(params[:guw_model_id]).guw_attributes
  end

  def new
    @guw_attribute = Guw::GuwAttribute.new
  end

  def edit
    @guw_attribute = Guw::GuwAttribute.find(params[:id])
  end

  def create
    @guw_attribute = Guw::GuwAttribute.new(params[:guw_attribute])
    @guw_attribute.save
    redirect_to guw.guw_model_path(@guw_attribute.guw_model)
  end

  def update
    @guw_attribute = Guw::GuwAttribute.find(params[:id])
    @guw_attribute.update_attributes(params[:guw_attribute])
    redirect_to guw.guw_model_path(@guw_attribute.guw_model)
  end
end
