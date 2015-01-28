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

require 'will_paginate/array'

class WbsActivitiesController < ApplicationController
  #include DataValidationHelper #Module for master data changes validation

  load_resource

  #Import a new WBS-Activities from a CVS file
  def import
    authorize! :manage, WbsActivity

    begin
      WbsActivityElement.import(params[:file], params[:separator])
      flash[:notice] = I18n.t (:notice_wbs_activity_element_import_successful)
    rescue => e
      flash[:error] = I18n.t (:error_wbs_activity_failed_file_integrity)
      flash[:warning] = "#{e}"
    end

    redirect_to :back
  end

  def refresh_ratio_elements
    authorize! :edit_wbs_activities, WbsActivity

    @wbs_activity_ratio_elements = []
    @wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])

    @wbs_activity_organization = @wbs_activity_ratio.wbs_activity.organization
    @wbs_organization_profiles = @wbs_activity_organization.nil? ? [] : @wbs_activity_organization.organization_profiles

    wbs_activity_elements_list = WbsActivityElement.where(:wbs_activity_id => @wbs_activity_ratio.wbs_activity.id).all
    @wbs_activity_elements = WbsActivityElement.sort_by_ancestry(wbs_activity_elements_list)
    @wbs_activity_ratio_elements = @wbs_activity_ratio.wbs_activity_ratio_elements.all
    @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
  end

  def index
    #No authorize required since everyone can access the list of ABS
    set_page_title 'WBS activities'
    #@wbs_activities = WbsActivity.all
    # Need to show only wbs-activities of current_user's organizations
    @wbs_activities = WbsActivity.where('organization_id IN (?)', current_user.organizations)
  end

  def edit
    #no authorize required since everyone can show this object

    set_page_title 'WBS activities'
    @wbs_activity = WbsActivity.find(params[:id])
    @organization_id = @wbs_activity.organization_id

    @wbs_activity_elements_list = @wbs_activity.wbs_activity_elements
    @wbs_activity_elements = WbsActivityElement.sort_by_ancestry(@wbs_activity_elements_list)
    @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios

    unless @wbs_activity_ratios.empty?
      @wbs_activity_organization = @wbs_activity_ratios.first.wbs_activity.organization
    end
    @wbs_organization_profiles = @wbs_activity_organization.nil? ? [] : @wbs_activity_organization.organization_profiles

    @wbs_activity_ratio_elements = []
    unless @wbs_activity.wbs_activity_ratios.empty?
      @wbs_activity_ratio_elements = @wbs_activity.wbs_activity_ratios.first.wbs_activity_ratio_elements.all
      @total = @wbs_activity_ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)
    else
      @total = 0
    end
  end

  def update
    authorize! :edit_wbs_activities, WbsActivity

    @wbs_activity = WbsActivity.find(params[:id])
    @wbs_activity_elements = @wbs_activity.wbs_activity_elements
    @wbs_activity_ratios = @wbs_activity.wbs_activity_ratios
    @wbs_activity_organization = @wbs_activity.organization || Organization.find(params[:wbs_activity][:organization_id])
    @wbs_organization_profiles =  @wbs_activity_organization.organization_profiles
    @organization_id = @wbs_activity_organization.id

    unless @wbs_activity.wbs_activity_ratios.empty?
      @wbs_activity_ratio_elements = @wbs_activity.wbs_activity_ratios.first.wbs_activity_ratio_elements
    end

    if @wbs_activity.update_attributes(params[:wbs_activity])
      #redirect_to redirect(wbs_activities_path), :notice => "#{I18n.t(:notice_wbs_activity_successful_updated)}"
      redirect_to redirect_apply(edit_organization_wbs_activity_path(@organization_id, @wbs_activity), nil, edit_organization_path(@organization_id, :anchor => 'wbs-activities')), :notice => "#{I18n.t(:notice_wbs_activity_successful_added)}"
    else
      render :edit
    end
  end

  def new
    authorize! :manage, WbsActivity

    set_page_title 'WBS activities'
    @wbs_activity = WbsActivity.new
    @organization_id = params['organization_id']
  end

  def create
    authorize! :manage, WbsActivity

    @wbs_activity = WbsActivity.new(params[:wbs_activity])
    @organization_id = params['wbs_activity']['organization_id']

    if @wbs_activity.save
      @wbs_activity_element = WbsActivityElement.new(:name => @wbs_activity.name, :wbs_activity_id => @wbs_activity.id, :description => 'Root Element', :is_root => true)
      @wbs_activity_element.save
        redirect_to edit_organization_wbs_activity_path(@organization_id, @wbs_activity), :notice => "#{I18n.t(:notice_wbs_activity_successful_added)}"
    else
      render :new
    end
  end

  def destroy
    authorize! :manage, WbsActivity

    @wbs_activity = WbsActivity.find(params[:id])
    @organization_id = @wbs_activity.organization_id
    @wbs_activity.destroy

    flash[:notice] = I18n.t(:notice_wbs_activity_successful_deleted)
    redirect_to edit_organization_path(@organization_id, anchor: 'wbs-activities')
  end


  #Method to duplicate WBS-Activity and associated WBS-Activity-Elements
  def duplicate_wbs_activity
    authorize! :manage, WbsActivity

    #Update ancestry depth caching
    WbsActivityElement.rebuild_depth_cache!

    begin
      old_wbs_activity = WbsActivity.find(params[:wbs_activity_id])
      new_wbs_activity = old_wbs_activity.amoeba_dup   #amoeba gem is configured in WbsActivity class model

      new_wbs_activity.transaction do
        if new_wbs_activity.save(:validate => false)
          old_wbs_activity.save  #Original WbsActivity copy number will be incremented to 1

          #we also have to save to wbs_activity_ratio
          old_wbs_activity.wbs_activity_ratios.each do |ratio|
            ratio.save
          end

          #get new WBS Ratio elements
          new_wbs_activity_ratio_elts = []
          new_wbs_activity.wbs_activity_ratios.each do |ratio|
            ratio.wbs_activity_ratio_elements.each do |ratio_elt|
              new_wbs_activity_ratio_elts << ratio_elt
            end
          end

          #Managing the component tree
          old_wbs_activity_elements = old_wbs_activity.wbs_activity_elements.order('ancestry_depth asc')
          old_wbs_activity_elements.each do |old_elt|
            new_elt = old_elt.amoeba_dup
            new_elt.wbs_activity_id = new_wbs_activity.id
            new_elt.save(:validate => false)

            unless new_elt.is_root?
              new_ancestor_ids_list = []
              new_elt.ancestor_ids.each do |ancestor_id|
                #ancestor_id = WbsActivityElement.find_by_wbs_activity_id_and_copy_id(new_elt.wbs_activity_id, ancestor_id).id
                ancestor = WbsActivityElement.find_by_wbs_activity_id_and_copy_id(new_elt.wbs_activity_id, ancestor_id)
                ancestor_id = ancestor.id
                new_ancestor_ids_list.push(ancestor_id)
              end
              new_elt.ancestry = new_ancestor_ids_list.join('/')

              corresponding_ratio_elts = new_wbs_activity_ratio_elts.select { |ratio_elt| ratio_elt.wbs_activity_element_id == new_elt.copy_id}.each do |ratio_elt|
                ratio_elt.update_attribute('wbs_activity_element_id', new_elt.id)
              end

              new_elt.save(:validate => false)
            end
          end
        else
          flash[:error] = "#{new_wbs_activity.errors.full_messages.to_sentence}"
        end
      end

      redirect_to('/wbs_activities', :notice  =>  "#{I18n.t(:notice_wbs_activity_successful_duplicated)}") and return

    rescue ActiveRecord::RecordNotSaved => e
      flash[:error] = "#{new_wbs_activity.errors.full_messages.to_sentence}"

    rescue
      flash[:error] = I18n.t(:error_wbs_activity_failed_duplicate) + "#{new_wbs_activity.errors.full_messages.to_sentence.to_s}"
      redirect_to '/wbs_activities'
    end
  end

  #This function will validate the WBS-Activity and all its elements
  def validate_change_with_children
    authorize! :manage, WbsActivity
    begin
      wbs_activity = WbsActivity.find(params[:id])
      #wbs_activity.record_status = @defined_status
      wbs_activity_root_element = WbsActivityElement.where('wbs_activity_id = ? and is_root = ?', wbs_activity.id, true).first

      wbs_activity.transaction do
        if wbs_activity.save

          wbs_activity_root_element.transaction do
            subtree = wbs_activity_root_element.subtree #all descendants (direct and indirect children) and itself
          end

          #TODO : Validate also Ratio and Ratio_Element of each wbs_activity_element
          wbs_activity_ratios = wbs_activity.wbs_activity_ratios
          wbs_activity_ratios.each do |ratio|
            ratio.transaction do
              #ratio.record_status = @defined_status
              if ratio.save
                wbs_activity_ratio_elements = ratio.wbs_activity_ratio_elements
                #wbs_activity_ratio_elements.update_all(:record_status_id => @defined_status.id)
              end
            end
          end

          flash[:notice] =I18n.t(:notice_wbs_activity_successful_updated)
        else
          flash[:error] = I18n.t(:error_wbs_activity_failed_update)+ ' ' +wbs_activity_root_element.errors.full_messages.to_sentence+'.'
        end
      end

      redirect_to :back

    rescue ActiveRecord::StatementInvalid => error
      put "#{error.message}"
      flash[:error] = "#{error.message}"
      redirect_to :back and return
    rescue ActiveRecord::RecordInvalid => err
      flash[:error] = "#{err.message}"
      redirect_to :back
    end
  end


protected

  def wbs_record_statuses_collection
    #No authorize required since this method is protected and won't be call from route
    if @wbs_activity.new_record?
      if is_master_instance?
        @wbs_record_status_collection = RecordStatus.where('name = ?', 'Proposed').defined
      else
        @wbs_record_status_collection = RecordStatus.where('name = ?', 'Local').defined
      end
    else
      @wbs_record_status_collection = []
      if @wbs_activity.is_defined?
        @wbs_record_status_collection = RecordStatus.where('name = ?', 'Defined').defined
      else
        @wbs_record_status_collection = RecordStatus.where('name <> ?', 'Defined').defined
      end
    end
  end

  #Function that enable/disable to update
  def enable_update_in_local?
    #No authorize required since this method is protected and won't be call from route
    if is_master_instance?
      true
    else
      if params[:action] == 'new'
        true
      elsif params[:action] == 'edit'
        @wbs_activity = WbsActivity.find(params[:id])
        #if @wbs_activity.is_local_record? && @wbs_activity.defined?
        if @wbs_activity.is_defined? || @wbs_activity.defined?
          false
        else
          true
        end
      end
    end
  end

end
