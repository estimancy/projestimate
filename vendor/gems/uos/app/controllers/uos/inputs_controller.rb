class Uos::InputsController < ApplicationController

  def index
    @module_project = ModuleProject.find(params[:mp])
    @pbs = current_component
    @inputs = Input.where(module_project_id: @module_project, pbs_project_element_id: @pbs.id).all
    @organization_technologies = current_project.organization.organization_technologies.map{|i| [i.name, i.id]}
    @unit_of_works = current_project.organization.unit_of_works.map{|i| [i.name, i.id]}
    @complexities = []
    organization_unit_of_works = current_project.organization.unit_of_works.first
    if !organization_unit_of_works.nil?
      @complexities = organization_unit_of_works.organization_uow_complexities.map{|i| [i.name, i.id]}
    end

    @module_project.pemodule.attribute_modules.each do |am|
      if am.pe_attribute.alias ==  "size"
        @size = EstimationValue.where(:module_project_id => @module_project.id,
                                      :pe_attribute_id => am.pe_attribute.id,
                                      :in_out => "input" ).first
      else
        @gross_size = EstimationValue.where(:module_project_id => @module_project.id,
                                            :pe_attribute_id => am.pe_attribute.id,
                                            :in_out => "output" ).first
      end
    end

    def new_item
      @module_project = ModuleProject.find(params[:mp])
      @pbs = PbsProjectElement.find(params[:pbs_id])
      input = Input.create(module_project_id: @module_project.id, pbs_project_element_id: @pbs.id)
      redirect_to redirect_apply("/uos?mp=#{@module_project.id}", "/uos?mp=#{@module_project.id}",  "/dashboard")
    end

    def remove_item
      input = Input.find(params[:input_id])
      @module_project = input.module_project
      input.delete
      redirect_to redirect_apply("/uos?mp=#{@module_project.id}", "/uos?mp=#{@module_project.id}",  "/dashboard")
    end

    def export
      csv_string = Input::export(params[:mp], params[:pbs_id])
      send_data(csv_string, :type => 'text/csv; header=present', :disposition => "attachment; filename=uo.csv")
    end

    def import
      csv_string = Input::import(params[:file], params[:separator], params[:encoding])
      redirect_to main_app.root_url
    end

    def save_uos
      @module_project = ModuleProject.find(params[:module_project_id])
      @organization_technologies = current_project.organization.organization_technologies.defined.map{|i| [i.name, i.id]}
      @unit_of_works = current_project.organization.unit_of_works.defined.map{|i| [i.name, i.id]}
      @complexities = current_project.organization.unit_of_works.first.organization_uow_complexities.map{|i| [i.name, i.id]}
      @gross = []

      params[:input_id].keys.each do |r|
        input = Input.where(id: params[:input_id]["#{r}"].to_i).first
        input.name = params[:name]["#{r}"]
        input.module_project_id = params[:module_project_id]
        input.technology_id = params[:technology]["#{r}"]
        input.unit_of_work_id = params[:uow]["#{r}"]
        input.complexity_id = params[:complexity]["#{r}"]
        input.size_low = params[:size_low]["#{r}"]
        input.size_most_likely = params[:size_most_likely]["#{r}"]
        input.size_high = params[:size_high]["#{r}"]
        input.weight = params[:weight]["#{r}"]
        input.gross_low = params[:gross_low]["#{r}"]
        input.gross_most_likely = params[:gross_most_likely]["#{r}"]
        input.gross_high = params[:gross_high]["#{r}"]
        input.flag = params[:flag]["#{r}"]
        input.save

        inputs = Input.where(id: params[:input_id]["#{r}"].to_i)
        @gross << inputs.first
      end

      @module_project.pemodule.attribute_modules.each do |am|
        @in_ev = EstimationValue.where(:module_project_id => @module_project.id, :pe_attribute_id => am.pe_attribute.id).first

        ["low", "most_likely", "high"].each do |level|
          if am.pe_attribute.alias == "size"
            level_est_val = @in_ev.send("string_data_#{level}")
            level_est_val[current_component.id] = @gross.map(&:"size_#{level}").compact.sum
          elsif am.pe_attribute.alias == "effort_man_hour"
            level_est_val = @in_ev.send("string_data_#{level}")
            level_est_val[current_component.id] = @gross.map(&:"gross_#{level}").compact.sum
          end
          @in_ev.update_attribute(:"string_data_#{level}", level_est_val)
        end
      end

      redirect_to redirect_apply("/uos?mp=#{@module_project.id}", "/uos?mp=#{@module_project.id}",  "/dashboard")
    end

    def load_gross
      @size = Array.new
      @tmp_result = Hash.new
      @result = Hash.new
      @level = ["gross_low", "gross_most_likely", "gross_high"]

      @size << params[:size_low]
      @size << params[:size_ml]
      @size << params[:size_high]

      if params['index']
        @index = params['index'].to_i - 2
      else
        @index = 1
      end

      productivity_ratio = OrganizationTechnology.find(params[:technology]).productivity_ratio
      abacus_value = OrganizationUowComplexity.find(params[:complexity]).value

      weight = params[:"weight"].nil? ? 1 : params[:"weight"]

      @result[:"gross_low_#{@index.to_s}"] = params[:size_low].to_i * abacus_value.to_f * weight.to_f * productivity_ratio.to_f
      @result[:"gross_most_likely_#{@index.to_s}"] = params[:size_most_likely].to_i * abacus_value * weight.to_f * productivity_ratio.to_f
      @result[:"gross_high_#{@index.to_s}"] = params[:size_high].to_i * abacus_value * weight.to_f * productivity_ratio.to_f
    end

    def update_complexity_select_box
      @complexities = OrganizationUowComplexity.where(unit_of_work_id: params[:uow_id]).all.map{|i| [i.name, i.id]}
      @index = params[:index]
    end

  end
end