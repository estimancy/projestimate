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

class PeiconsController < ApplicationController
  load_resource

  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  def index
    authorize! :create_and_edit_projestimate_icons, Peicon

    set_page_title 'Icons libraries'
    @icons = Peicon.all
  end

  def new
    authorize! :create_and_edit_projestimate_icons, Peicon

    set_page_title 'Icons libraries'
    @icon = Peicon.new
  end

  def edit
    authorize! :create_and_edit_projestimate_icons, Peicon

    set_page_title 'Icons libraries'
    @icon = Peicon.find(params[:id])

    unless @icon.child_reference.nil?
      if @icon.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_icon_cant_be_edit)
        redirect_to peicons_path
      end
    end
  end

  def create
    authorize! :create_and_edit_projestimate_icons, Peicon

    set_page_title 'Icons libraries'
    @icon = Peicon.new(params[:peicon])
    if @icon.save
      redirect_to redirect_apply(nil,new_peicon_path(), peicons_path )
    else
      flash[:error] = I18n.t(:icons) + " #{ @icon.errors.values.flatten.join( I18n.t('support.array.two_words_connector'))}"
      render :new
    end
  end

  def update
    authorize! :create_and_edit_projestimate_icons, Peicon

    set_page_title 'Icons libraries'
    @icon = nil
    current_icon = Peicon.find(params[:id])
    if current_icon.is_defined?
      @icon = current_icon.amoeba_dup
      @icon.owner_id = current_user.id
    else
      @icon = current_icon
    end

    if @icon.update_attributes(params[:peicon])
      redirect_to redirect_apply(edit_peicon_path(@icon), nil, peicons_path )
    else
      flash[:error] = I18n.t(:icons) + " #{ @icon.errors.values.flatten.join(" I18n.t ('support.array.two_words_connector') ")}"
      render :edit
    end
  end

  def destroy
    authorize! :manage, Peicon

    @peicon = Peicon.find(params[:id])
    if @peicon.is_defined? || @peicon.is_custom?
      #logical deletion: delete don't have to suppress records anymore
      @peicon.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
    else
      @peicon.icon = nil
      @peicon.save
      @peicon.destroy
    end

    redirect_to peicons_path, :notice => "#{I18n.t (:notice_icon_successful_deleted)}"
  end

  def choose_icon
    authorize! :create_and_edit_projestimate_icons, Peicon

    @peicon = Peicon.find(params[:id])
  end
end
