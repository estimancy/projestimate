#encoding: utf-8
#########################################################################
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
#    ===================================================================
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

class AttributeModulesController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  def create
    authorize! :manage, PeAttribute
    @attribute_module = AttributeModule.new(params[:attribute_module])

    if @attribute_module.save
      redirect_to attribute_modules_path, notice: "#{I18n.t(:notice_attribute_module_successful_created)}"
    else
      render action: "new"
    end
  end

  def destroy
    authorize! :manage, PeAttribute
    @attribute_module = AttributeModule.find(params[:id])
    if @attribute_module.is_defined? || @attribute_module.is_custom?
      #logical deletion: delete don't have to suppress records anymore
      @attribute_module.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @attribute_module.destroy
    end

    redirect_to edit_pemodule_path(@attribute_module.pemodule)
  end

  def check_attribute_modules
    authorize! :manage, PeAttribute
    unless params[:attr_id].eql?("undefined") || params[:attr_id].nil?
      @attr = AttributeModule.find(params[:attr_id])
      @is_valid = @attr.is_validate(params[:value])
      @level = params[:level]
      @est_val_id = params[:est_val_id]
    end
  end

end
