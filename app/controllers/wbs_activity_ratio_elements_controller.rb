class WbsActivityRatioElementsController < ApplicationController
  include DataValidationHelper #Module for master data changes validation

  before_filter :get_record_statuses

  def edit
    set_page_title "Edit wbs-activity ratio"
    @wbs_activity_ratio_element = WbsActivityRatioElement.find(params[:id])
  end

  def new
    set_page_title "New wbs-activity ratio"
    @wbs_activity_ratio_element = WbsActivityRatioElement.new
  end

  def save_values
    #set ratio values
    ratio_values = params[:ratio_values]
    ratio_values.each do |i|
      WbsActivityRatioElement.find(i.first).update_attribute('ratio_value', i.last)
    end

    wbs_activity_ratio = WbsActivityRatio.find(params[:wbs_activity_ratio_id])
    ratio_elements = wbs_activity_ratio.wbs_activity_ratio_elements

    #sum total ratio_value
    total = ratio_elements.reject{|i| i.ratio_value.nil? or i.ratio_value.blank? }.compact.sum(&:ratio_value)

    #set ratio reference (all to false then one to true)
    wbs_activity_ratio.wbs_activity_ratio_elements.each do |wbs_activity_ratio_element|
      wbs_activity_ratio_element.update_attribute("ratio_reference_element",  false)
    end

    if params[:ratio_reference_element].nil?
      flash[:error] = "Please select a reference element"
      redirect_to redirect(edit_wbs_activity_path(wbs_activity_ratio.wbs_activity, :anchor => "tabs-4")) and return
    else
      new_ref = WbsActivityRatioElement.find_by_id_and_wbs_activity_ratio_id(params[:ratio_reference_element], params[:wbs_activity_ratio_id])
      new_ref.update_attribute("ratio_reference_element", true)
    end

    #test total
    if total != 100
      flash[:warning] = "Warning - Ratios successfully saved, but sum is different of 100%"
    else
      flash[:notice] = "Ratios successfully saved"
    end

    redirect_to edit_wbs_activity_path(wbs_activity_ratio.wbs_activity, :anchor => "tabs-4")

  end

end
