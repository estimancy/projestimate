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


class Guw::GuwAttributeComplexitiesController < ApplicationController
  def index
    @guw_attribute_complexities = Guw::GuwAttributeComplexity.all
  end

  def new
    @guw_attribute_complexity = Guw::GuwAttributeComplexity.new
  end

  def edit
    @guw_attribute_complexity = Guw::GuwAttributeComplexity.find(params[:id])
  end

  def create
    @guw_attribute_complexity = Guw::GuwAttributeComplexity.new(params[:guw_attribute_complexity])
    @guw_attribute_complexity.save
    redirect_to main_app.root_url
  end

  def update
    @guw_attribute_complexity = Guw::GuwAttributeComplexity.find(params[:id])
    @guw_attribute_complexity.update_attributes(params[:guw_attribute_complexity])
    redirect_to main_app.root_url
  end
end
