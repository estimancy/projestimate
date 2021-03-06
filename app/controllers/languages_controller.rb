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

class LanguagesController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses
  load_resource

  def index
    authorize! :manage_master_data, :all

    set_page_title 'Languages'
    @languages = Language.all
  end

  def new
    authorize! :manage, Language
    set_page_title 'Add a language'
    @language = Language.new
  end

  def edit
    authorize! :manage_master_data, :all
    set_page_title 'Edit language'
    @language = Language.find(params[:id])

    unless @language.child_reference.nil?
      if @language.child_reference.is_proposed_or_custom?
        flash[:warning] = I18n.t (:warning_language_cant_be_edit)
        redirect_to languages_path
      end
    end
  end

  def create
    authorize! :manage_master_data, :all

    @language = Language.new(params[:language])
    @language.record_status = @proposed_status
    if @language.save
      flash[:notice] = I18n.t (:notice_language_successful_created)
      redirect_to redirect_apply(nil, new_language_path(), languages_path)
      else
      render action: 'new'
    end
  end

  def update
    authorize! :manage_master_data, :all

    @language = nil
    current_language = Language.find(params[:id])
    if current_language.is_defined?
      @language = current_language.amoeba_dup
      @language.owner_id = current_user.id
    else
      @language = current_language
    end

    if @language.update_attributes(params[:language])
      flash[:notice] = I18n.t (:notice_language_successful_updated)
      redirect_to redirect_apply(edit_language_path(@language), nil, languages_path)
      else
      flash[:error] = "#{I18n.t (:error_language_failed_update)}"+"#{@language.errors.full_messages.to_sentence}"
      render action: 'edit'
    end
  end

  # Destroy method on Master table is not going to delete  definitively the record
  #It is only going to change ths record status : logical deletion
  def destroy
    authorize! :manage_master_data, :all

    @language = Language.find(params[:id])
    #if @language.is_defined? || @language.is_custom?
    if @language.is_custom?
      #logical deletion  delete don't have to suppress records anymore on Defined record
      @language.update_attributes(:record_status_id => @retired_status.id, :owner_id => current_user.id)
      flash[:notice] = I18n.t (:notice_language_successful_deleted)
    elsif @language.is_defined?
      flash[:warning] = I18n.t(:defined_language_not_deletable)
    else
      @language.destroy
      flash[:notice] = I18n.t (:notice_language_successful_deleted)
    end

    respond_to do |format|
      format.html { redirect_to languages_url }
    end
  end

end
