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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################


class Ge::GeModelsController < ApplicationController

  require 'rubyXL'

  def show
    authorize! :show_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    @organization = @ge_model.organization

    set_page_title @ge_model.name
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:effort_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @ge_model.name => ""
  end

  def new
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:organization_id])
    @ge_model = Ge::GeModel.new
    set_page_title I18n.t(:new_instance_of_effort)
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:effort_modules) => main_app.organization_module_estimation_path(params['organization_id'], anchor: "effort"), I18n.t(:new) => ""
  end

  def edit
    authorize! :show_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    @organization = @ge_model.organization

    set_page_title I18n.t(:Edit_instance_of_effort)
    #set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", I18n.t(:effort_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @ge_model.organization => ""
    set_breadcrumbs I18n.t(:organizations) => "/organizationals_params", @organization.to_s => main_app.organization_estimations_path(@organization), I18n.t(:effort_modules) => main_app.organization_module_estimation_path(@organization, anchor: "effort"), @ge_model.name => ""

  end

  def create
    authorize! :manage_modules_instances, ModuleProject

    @organization = Organization.find(params[:ge_model][:organization_id])

    @ge_model = Ge::GeModel.new(params[:ge_model])
    @ge_model.organization_id = params[:ge_model][:organization_id].to_i
    if @ge_model.save
      redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
    else
      render action: :new
    end

  end

  def update
    authorize! :manage_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    @organization = @ge_model.organization

    if @ge_model.update_attributes(params[:ge_model])
      redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
    else
      render action: :edit
    end
  end

  def destroy
    authorize! :manage_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:id])
    organization_id = @ge_model.organization_id

    @ge_model.module_projects.each do |mp|
      mp.destroy
    end

    @ge_model.delete
    redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
  end


  # Import Data with Excel files
  def import
    authorize! :manage_modules_instances, ModuleProject

    @ge_model = Ge::GeModel.find(params[:ge_model_id])

    Ge::GeFactor.destroy_all("ge_model_id = #{@ge_model.id}")

    factors_list = Array.new
    factors_values = Array.new
    sheet1_order = { :"0" => "scale_prod", :"1" => "type", :"2" => "short_name_factor", :"3" => "long_name_factor", :"4" => "description" }
    sheet2_order = { :"0" => "factor", :"1" => "text", :"2" => "value" }

    #if !params[:file].nil? && (File.extname(params[:file].original_filename) == ".xlsx" || File.extname(params[:file].original_filename) == ".Xlsx")
    if !params[:file].nil? && (File.extname(params[:file].original_filename).in? [".xlsx", ".Xlsx", ".xsl"])
      workbook = RubyXL::Parser.parse(params[:file].path)
      #tab1 = workbook[0].extract_data

      # We must have 2 sheets in this file
      filename = params[:file].original_filename
      worksheet1 = workbook['Factors']  # workbook[0]    # Sheet of the list of Factors
      worksheet2 = workbook['Values']    # Sheet of the factors values

      # feuille1 : worksheet1.dimension.ref.row_range
      worksheet1.each_with_index do |row, index|
        if index > 0
          row_factor = Hash.new

          row && row.cells.each do |cell|
            val = cell && cell.value

            #add value to table
            key_name = sheet1_order["#{cell.column}".to_sym]
            row_factor["#{key_name}"] = val
          end

          unless row_factor.empty?
            #factors_list << row_factor

            #Create data in factors table
            #sheet1_order = { :"0" => "scale_prod", :"1" => "type", :"2" => "short_name_factor", :"3" => "long_name_factor", :"4" => "description" }
            short_name_factor = row_factor["short_name_factor"]
            factor_alias = short_name_factor.nil? ? "" : short_name_factor.gsub(/( )/, '_').downcase
            Ge::GeFactor.create(ge_model_id: @ge_model.id, short_name: short_name_factor, long_name: row_factor["long_name_factor"], factor_type: row_factor["type"],
                                     scale_prod: row_factor["scale_prod"],  data_filename: filename, description: row_factor["description"], alias: factor_alias)
          end
        end
      end

      # feuille2
      worksheet2.each_with_index do |row, index|
        if index > 0
          row_factor = Hash.new

          row && row.cells.each do |cell|
            val = cell && cell.value

            #add value to table
            key_name = sheet2_order["#{cell.column}".to_sym]
            row_factor["#{key_name}"] = val unless key_name.nil?
          end

          unless row_factor.empty?
            #factors_values << row_factor

            #Create data in factors values table
            #sheet2_order = { :"0" => "factor", :"1" => "text", :"2" => "value" }
            #FactorValues ==> :name, :alias, :value_number, :value_text, :ge_factor_id, :ge_model_id
            factor_name = row_factor["factor"]
            factor_alias = factor_name.gsub(/( )/, '_').downcase
            factors = @ge_model.ge_factors.where(alias: factor_alias)
            unless factors.nil?
              factor = factors.first
              factor_value = Ge::GeFactorValue.create(ge_model_id: @ge_model.id, ge_factor_id: factor.id, factor_alias: factor_alias, factor_scale_prod: factor.scale_prod,
                                                      factor_type: factor.factor_type, factor_name: factor_name, value_text: row_factor["text"], value_number: row_factor["value"])
            end
          end
        end
      end
    else
      flash[:error] =  I18n.t(:route_flag_error_4)
    end

    redirect_to ge.edit_ge_model_path(@ge_model, anchor: "tabs-2")
  end


  def save_efforts
    authorize! :execute_estimation_plan, @project

    @ge_model = Ge::GeModel.find(params[:ge_model_id])
    @ge_input = @ge_model.ge_inputs.where(module_project_id: current_module_project.id).first_or_create

    # Get factors values and save them in the GeInput table
    # GeInput "values" attribute is serialize as an Array of Hash  ==> [ { :ge_factor_value_id => id, :scale_prod => val, :factor_name =>, :value => val }, {...}, ... ]
    scale_factor_sum = 0.0
    prod_factor_product = 1.0
    scale_factors = params["S_factor"]
    prod_factors = params["P_factor"]

    @ge_input_values = Hash.new
    #Save Scale Factors data in GeInput table
    scale_factors.each do |key, factor_value_id|
      factor_value = Ge::GeFactorValue.find(factor_value_id)
      unless factor_value.nil?
        factor_value_number = factor_value.value_number
        scale_factor_sum += factor_value_number
        value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
        @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
      end
    end

    #Save Prod Factors data in GeInput table
    prod_factors.each do |key, factor_value_id|
      factor_value = Ge::GeFactorValue.find(factor_value_id)
      unless factor_value.nil?
        factor_value_number = factor_value.value_number
        prod_factor_product *= factor_value_number
        value_per_factor = { :ge_factor_value_id => factor_value.id, :scale_prod => factor_value.factor_scale_prod, :factor_name => factor_value.factor_name, :value => factor_value_number }
        @ge_input_values["#{factor_value.factor_alias}"] = value_per_factor
      end
    end

    #Update GeInput
    @formula = "#{prod_factor_product.to_f} X ^ #{scale_factor_sum.to_f}"
    @ge_input.formula = @formula
    @ge_input.scale_factor_sum = scale_factor_sum
    @ge_input.prod_factor_product = prod_factor_product
    @ge_input.values = @ge_input_values
    @ge_input.save


    current_module_project.pemodule.attribute_modules.each do |am|
      tmp_prbl = Array.new

      ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first
      ["low", "most_likely", "high"].each do |level|

        if @ge_model.three_points_estimation?
          size = params["retained_size_#{level}"].to_f
        else
          size = params["retained_size_most_likely"].to_f
        end

        if am.pe_attribute.alias == "effort"
          ###effort = (@ge_model.coeff_a * size ** @ge_model.coeff_b) * @ge_model.standard_unit_coefficient

          #The effort value will be calculated as : Effort = p * Taille^s
          # with: s = sum of scale factors      and  p = multiply of prod factors
          if scale_factor_sum == 0
            scale_factor_sum = 1
          end
          effort = (prod_factor_product * (size ** scale_factor_sum)) #* @ge_model.standard_unit_coefficient

          ev.send("string_data_#{level}")[current_component.id] = effort
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        elsif am.pe_attribute.alias == "retained_size"
          ev = EstimationValue.where(:module_project_id => current_module_project.id, :pe_attribute_id => am.pe_attribute.id).first
          ev.send("string_data_#{level}")[current_component.id] = size
          ev.save
          tmp_prbl << ev.send("string_data_#{level}")[current_component.id]
        end
      end

      unless @ge_model.three_points_estimation?
        tmp_prbl[0] = tmp_prbl[1]
        tmp_prbl[2] = tmp_prbl[1]
      end

      ev.update_attribute(:"string_data_probable", { current_component.id => ((tmp_prbl[0].to_f + 4 * tmp_prbl[1].to_f + tmp_prbl[2].to_f)/6) } )

    end

    current_module_project.nexts.each do |n|
      ModuleProject::common_attributes(current_module_project, n).each do |ca|
        ["low", "most_likely", "high"].each do |level|
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_#{level}", { current_component.id => nil } )
          EstimationValue.where(:module_project_id => n.id, :pe_attribute_id => ca.id).first.update_attribute(:"string_data_probable", { current_component.id => nil } )
        end
      end
    end

    #@current_organization.fields.each do |field|
      current_module_project.views_widgets.each do |vw|
        ViewsWidget::update_field(vw, @current_organization, current_module_project.project, current_component)
      end
    #end

    redirect_to main_app.dashboard_path(@project)
  end


  #duplicate GeModel
  def duplicate
    @ge_model = Ge::GeModel.find(params[:ge_model_id])
    new_ge_model = @ge_model.amoeba_dup

    new_copy_number = @ge_model.copy_number.to_i+1
    new_ge_model.name = "#{@ge_model.name}(#{new_copy_number})"
    new_ge_model.copy_number = 0
    @ge_model.copy_number = new_copy_number

    #Terminate the model duplication
    new_ge_model.transaction do
      if new_ge_model.save
        @ge_model.save
        flash[:notice] = "Modèle copié avec succès"
      else
        flash[:error] = "Erreur lors de la copie du modèle"
      end
    end

    redirect_to main_app.organization_module_estimation_path(@ge_model.organization_id, anchor: "effort")
  end

end
