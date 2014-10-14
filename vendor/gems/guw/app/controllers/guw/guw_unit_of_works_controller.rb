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
#############################################################################


class Guw::GuwUnitOfWorksController < ApplicationController
  def new
    @guw_unit_of_work = Guw::GuwUnitOfWork.new
  end

  def edit
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
  end

  def create
    @guw_unit_of_work = Guw::GuwUnitOfWork.new(params[:guw_unit_of_work])
    @guw_unit_of_work.save
    redirect_to main_app.root_url
  end

  def update
    @guw_unit_of_work = Guw::GuwUnitOfWork.find(params[:id])
    @guw_unit_of_work.update_attributes(params[:guw_unit_of_work])
    redirect_to main_app.root_url
  end

end
