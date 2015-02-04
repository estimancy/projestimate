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
  include ModuleProjectsHelper
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

  def save_effort_breakdown
    @pbs_project_element = current_component
    @tmp_results = Hash.new

    level_estimation_value = Hash.new
    current_pbs_estimations = current_module_project.estimation_values
    current_pbs_estimations.each do |est_val|
      if est_val.in_out == 'output'

        @results = Hash.new
        tmp_prbl = Array.new

        ["low", "most_likely", "high"].each do |level|
          eb = EffortBreakdown::EffortBreakdown.new(current_component, current_module_project, params[:values][level].to_f)

          @tmp_results[level.to_sym] = { "#{est_val.pe_attribute.alias}_#{current_module_project.id}".to_sym => eb.send("get_#{est_val.pe_attribute.alias}") }

          level_estimation_value[@pbs_project_element.id] = @tmp_results[level.to_sym]["#{est_val.pe_attribute.alias}_#{current_module_project.id.to_s}".to_sym]

          @results["string_data_#{level}"] = level_estimation_value
        end

        probable_estimation_value = Hash.new
        probable_estimation_value = est_val.send('string_data_probable')
        probable_estimation_value[@pbs_project_element.id] = probable_value(@tmp_results, est_val)

        ####### Get the project referenced ratio #####
        # Project wbs_activity
        wbs_activity = current_module_project.wbs_activity
        # Get the wbs_project_element which contain the wbs_activity_ratio
        wbs_activity_root = wbs_activity.wbs_activity_elements.first.root
        # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)

        # Use project default Ratio, unless PSB got its own Ratio,
        # If default ratio was defined in PBS, it will override the one defined in module-project
        ratio_reference = WbsActivityRatio.find(params[:ratio])

        # Get the referenced ratio wbs_activity_ratio_profiles
        referenced_wbs_activity_ratio_profiles = ratio_reference.wbs_activity_ratio_profiles
        profiles_probable_value = {}
        parent_profile_est_value = {}

        # get the wbs_project_elements that have at least one child
        wbs_activity_elements = wbs_activity.wbs_activity_elements.select{ |elt| elt.has_children? && !elt.is_root }.map(&:id)

        @project.organization.organization_profiles.each do |profile|
          profiles_probable_value["profile_id_#{profile.id}"] = Hash.new
          # Parent values are reset to zero
          wbs_activity_elements.each{ |elt| parent_profile_est_value["#{elt}"] = 0 }

          probable_estimation_value[@pbs_project_element.id].each do |wbs_activity_elt_id, hash_value|
            # Get the probable value profiles values

            if hash_value["profiles"].nil?
              # create a new hash for profiles estimations results
              probable_estimation_value[@pbs_project_element.id][wbs_activity_elt_id]["profiles"] = Hash.new
            end

            current_probable_profiles = probable_estimation_value[@pbs_project_element.id][wbs_activity_elt_id]["profiles"]

            wbs_activity_element = WbsActivityElement.find(wbs_activity_elt_id)
            wbs_activity_elt_id = wbs_activity_element.id

            # Wbs_project_element root element doesn't have a wbs_activity_element
            if !wbs_activity_elt_id.nil? ||
                wbs_activity_ratio_elt = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', ratio_reference.id, wbs_activity_elt_id).first
              if !wbs_activity_ratio_elt.nil?
                # get the wbs_activity_ratio_profile
                corresponding_ratio_profile = referenced_wbs_activity_ratio_profiles.where('wbs_activity_ratio_element_id = ? AND organization_profile_id = ?', wbs_activity_ratio_elt.id, profile.id).first
                # Get current profile ratio value for the referenced ratio
                corresponding_ratio_profile_value = corresponding_ratio_profile.nil? ? nil : corresponding_ratio_profile.ratio_value
                estimation_value_profile = nil
                unless corresponding_ratio_profile_value.nil?
                  estimation_value_profile = (hash_value[:value].to_f * corresponding_ratio_profile_value.to_f) / 100

                  #the update the parent's value
                  parent_profile_est_value["#{wbs_activity_element.parent_id}"] = parent_profile_est_value["#{wbs_activity_element.parent_id}"].to_f + estimation_value_profile
                end

                current_probable_profiles["profile_id_#{profile.id}"] = { "ratio_id_#{ratio_reference.id}" => {:value => estimation_value_profile} }
              end
            end
          end

          #Need to calculate the parents effort by profile : addition of its children values
          wbs_activity_elements.each do |wbs_activity_element_id|
            probable_estimation_value[@pbs_project_element.id][wbs_activity_element_id]["profiles"]["profile_id_#{profile.id}"] = { "ratio_id_#{ratio_reference.id}" => {:value => parent_profile_est_value["#{wbs_activity_element_id}"]} }
          end
        end

        @results['string_data_probable'] = probable_estimation_value
        #Update current pbs estimation values
        est_val.update_attributes(@results)
      elsif est_val.in_out == 'input'
        in_result = Hash.new
        tmp_prbl = Array.new
        ['low', 'most_likely', 'high'].each do |level|
          level_estimation_value = Hash.new
          level_estimation_value[@pbs_project_element.id] = params[:values][level]
          in_result["string_data_#{level}"] = level_estimation_value

          tmp_prbl << params[:values][level].to_f
        end

        est_val.update_attributes(in_result)

        est_val.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )
      end
    end
    redirect_to dashboard_path(@project)
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
