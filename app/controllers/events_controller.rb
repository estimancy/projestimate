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

class EventsController < ApplicationController
  load_resource

  def index
    authorize! :manage, Event

    set_page_title('Events')
    @events = Event.all
  end

  def new
    authorize! :manage, Event

    @event = Event.new
  end

  def edit
    authorize! :manage, Event

    @event = Event.find(params[:id])
  end

  def create
    authorize! :manage, Event

    @event = Event.new(params[:event])
    if @event.save
      flash[:notice] = I18n.t (:notice_event_successful_created)
      redirect_to redirect_apply(nil, new_event_path(), events_path)
    else
      render action: 'new'
    end
  end

  def update
    authorize! :manage, Event

    @event = nil
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:notice] = I18n.t (:notice_event_successful_updated)
      redirect_to redirect_apply(edit_event_path(@event), nil, events_path )
     else
      render action: 'edit'
    end

  end

  def destroy
    authorize! :manage, Event

    @event = Event.find(params[:id])
    @event.destroy
    redirect_to events_path
  end
end