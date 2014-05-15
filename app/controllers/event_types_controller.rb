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
#############################################################################

class EventTypesController < ApplicationController
  include DataValidationHelper #Module for master data changes validation
  load_resource

  before_filter :get_record_statuses

  def index
    @event_types = EventType.all
  end

  def new
    @event_type = EventType.new
  end

  def edit
    @event_type = EventType.find(params[:id])

    unless @event_type.child_reference.nil?
      if @event_type.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_event_type_cant_be_edit)
        redirect_to event_types_path
      end
    end
  end

  def create
    @event_type = EventType.new(params[:event_type])
    redirect_to event_types_path #event_type_url
  end

  def update
    @event_type = nil
    current_event_type = EventType.find(params[:id])
    if current_event_type.is_defined?
      @event_type = current_event_type.amoeba_dup
      @event_type.owner_id = current_user.id
    else
      @event_type = current_event_type
    end

    if @event_type.update_attributes(params[:event_type])
      redirect_to event_types_path, notice: "#{I18n.t (:notice_event_type_successful_updated)}"
    else
      render action: 'edit'
    end

  end

  def destroy
    @event_type = EventType.find(params[:id])
    if @event_type.is_defined? || @event_type.is_custom?
      #logical deletion: delete don't have to suppress records anymore on defined record
      @event_type.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @event_type.destroy
    end

    flash[:notice] = I18n.t (:notice_event_type_successful_deleted)
    redirect_to event_type_url
  end
end
