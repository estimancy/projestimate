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

#require_dependency "staffing/application_controller"

#module Staffing
  class Staffing::StaffingCustomDataController < ApplicationController

    # GET /staffing_custom_data
    # GET /staffing_custom_data.json
    def index
      @staffing_custom_data = StaffingCustomDatum.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @staffing_custom_data }
      end
    end
  
    # GET /staffing_custom_data/1
    # GET /staffing_custom_data/1.json
    def show
      @staffing_custom_datum = StaffingCustomDatum.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @staffing_custom_datum }
      end
    end
  
    # GET /staffing_custom_data/new
    # GET /staffing_custom_data/new.json
    def new
      @staffing_custom_datum = StaffingCustomDatum.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @staffing_custom_datum }
      end
    end
  
    # GET /staffing_custom_data/1/edit
    def edit
      @staffing_custom_datum = StaffingCustomDatum.find(params[:id])
    end
  
    # POST /staffing_custom_data
    # POST /staffing_custom_data.json
    def create
      @staffing_custom_datum = StaffingCustomDatum.new(params[:staffing_custom_datum])
  
      respond_to do |format|
        if @staffing_custom_datum.save
          format.html { redirect_to @staffing_custom_datum, notice: 'Staffing custom datum was successfully created.' }
          format.json { render json: @staffing_custom_datum, status: :created, location: @staffing_custom_datum }
        else
          format.html { render action: "new" }
          format.json { render json: @staffing_custom_datum.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /staffing_custom_data/1
    # PUT /staffing_custom_data/1.json
    def update
      @staffing_custom_datum = StaffingCustomDatum.find(params[:id])
  
      respond_to do |format|
        if @staffing_custom_datum.update_attributes(params[:staffing_custom_datum])
          format.html { redirect_to @staffing_custom_datum, notice: 'Staffing custom datum was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @staffing_custom_datum.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /staffing_custom_data/1
    # DELETE /staffing_custom_data/1.json
    def destroy
      @staffing_custom_datum = StaffingCustomDatum.find(params[:id])
      @staffing_custom_datum.destroy
  
      respond_to do |format|
        format.html { redirect_to staffing_custom_data_url }
        format.json { head :no_content }
      end
    end

    #Save Team/Staffing custom data
    def save_staffing_custom_data
      authorize! :execute_estimation_plan, @project

      @component = current_component
      @module_project = current_module_project
      @staffing_model = @module_project.staffing_model
      trapeze_default_values = @staffing_model.trapeze_default_values

      @staffing_custom_data = Staffing::StaffingCustomDatum.where(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: @component.id).first
      @staffing_model.trapeze_default_values =  { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] }

      if @staffing_custom_data.nil?
        @staffing_custom_data = Staffing::StaffingCustomDatum.create(staffing_model_id: @staffing_model.id, module_project_id: @module_project.id, pbs_project_element_id: @component.id,
                                          staffing_method: 'trapeze', period_unit: 'week', global_effort_type: 'probable', mc_donell_coef: 6, puissance_n: 0.33,
                                          trapeze_default_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] },
                                          trapeze_parameter_values: { :x0 => trapeze_default_values['x0'], :y0 => trapeze_default_values['y0'], :x1 => trapeze_default_values['x1'], :x2 => trapeze_default_values['x2'], :x3 => trapeze_default_values['x3'], :y3 => trapeze_default_values['y3'] } )
      end


      if @staffing_custom_data.update_attributes(params[:staffing_custom_datum])

        effort = @staffing_custom_data.global_effort_value
        duration = @staffing_custom_data.duration

        case @staffing_custom_data.staffing_method

          #================================= TRAPEZE / LINEAIRE  ===================================
          when 'trapeze'
            trapeze_parameter_values = @staffing_custom_data.trapeze_parameter_values

            # Calcul des vraies valeurs de (x0, x1, x2, x3) en % de la durée D ; et  (y0, y3) en % de M
            x0 = trapeze_parameter_values[:x0].to_f / 100
            x1 = trapeze_parameter_values[:x1].to_f / 100
            x2 = trapeze_parameter_values[:x2].to_f / 100
            x3 = trapeze_parameter_values[:x3].to_f / 100
            y0 = trapeze_parameter_values[:y0].to_f / 100
            y3 = trapeze_parameter_values[:y3].to_f / 100

            # Calcul du Max staffing M = 2 * (E/D) * (1 / (x3 + x2 - x1 - x0 + y0*(x1 - x2) + y3*(x3 - x2)))
            max_staffing = 2 * (effort/duration) * ( 1 / (x3 + x2 - x1 - x0 + y0*(x1 - x2) + y3*(x3 - x2)))
            @staffing_custom_data.max_staffing = max_staffing

            x0D = x0 * duration
            x1D = x1 * duration
            x2D = x2 * duration
            x3D = x3 * duration

            # Calcul de a, b, a', b' avec
            # a = M(1 - y0) / D(x1 - x2)
            coef_a = (max_staffing*(1-y0)) / (duration*(x1-x0))
            @staffing_custom_data.coef_a = coef_a

            # b = M(x1y0 - x0) / (x1 - x0)
            coef_b = (max_staffing * ((x1*y0) - x0)) / (x1-x0)
            @staffing_custom_data.coef_b = coef_b

            # a' = M(1 - y3) / D(x2 - x3)
            coef_a_prime = (max_staffing*(1-y3)) / (duration*(x2-x3))
            @staffing_custom_data.coef_a_prime = coef_a_prime

            # b' = M(x2y3 - x3) / D(x2 - x3)
            coef_b_prime = (max_staffing * ((x2*y3) - x3)) / (x2-x3)
            @staffing_custom_data.coef_b_prime = coef_b_prime

            # Calcul du Staffing f(x) pour la duree indiquee : intervalle de temps par defaut = 1 semaine
            # Creation du jeu de donnees pour le tracer la courbe
            staffing_values = []

            for t in 0..duration
              case t
                #intervalle_1 = x(semaine) compris dans [0 ; x0*D]     =>  f(x) = 0
                when 0..x0D
                  t_staffing = 0

                #intervalle_2 = x(semaine) compris dans ]x0*D ; x1*D]  =>   f(x) = ax+b
                when x0D..x1D
                  t_staffing = (coef_a * t) + coef_b

                #intervalle_3 = x(semaine) compris dans ]x1*D ; x2*D]  =>   f(x) = M
                when x1D..x2D
                  t_staffing = max_staffing

                #intervalle_4 = x(semaine) compris dans ]x2*D ; x3*D]   =>  f(x) = a'x+b'
                when x2D..x3D
                  t_staffing = (coef_a_prime * t) + coef_b_prime

                #intervalle_5 = x(semaine) compris dans ]x3*D ; infini[  => f(x) = 0
                else
                  t_staffing = 0
              end

              staffing_values << ["#{t}", t_staffing]
            end

            @staffing_custom_data.chart_theoretical_coordinates = staffing_values
            @staffing_custom_data.chart_actual_coordinates = staffing_values

            @staffing_custom_data.save


          #================================= RAYLEIGH  ==============================================

          when 'rayleigh'

          else

        end

      end

      redirect_to :back
    end


    #Update estimation values
    def update_staffing_estimation_values

    end

  end
#end