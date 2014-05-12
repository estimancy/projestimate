class CocomoAdvanced::InputCocomoController < ApplicationController
  def index
    @aprod = Array.new
    aliass = %w(rely data cplx ruse docu)
    aliass.each do |a|
      @aprod << Factor.where(alias: a, factor_type: "advanced").first
    end

    @aplat = Array.new
    aliass = %w(time stor pvol)
    aliass.each do |a|
      @aplat << Factor.where(alias: a, factor_type: "advanced").first
    end

    @apers = Array.new
    aliass = %w(acap aexp ltex pcap pexp pcon)
    aliass.each do |a|
      @apers << Factor.where(alias: a, factor_type: "advanced").first
    end

    @aproj = Array.new
    aliass = %w(tool site sced)
    aliass.each do |a|
      @aproj << Factor.where(alias: a, factor_type: "advanced").first
    end


  end

  def cocomo_save
    params['factors'].each do |factor|
      cmplx = OrganizationUowComplexity.find(factor[1])

      old_cocomos = InputCocomo.where(factor_id: factor[0].to_i,
                                     pbs_project_element_id: current_component.id,
                                     project_id: current_project.id,
                                     module_project_id: current_module_project.id)
      old_cocomos.delete_all

      InputCocomo.create(factor_id: factor[0].to_i,
                         organization_uow_complexity_id: cmplx.id,
                         pbs_project_element_id: current_component.id,
                         project_id: current_project.id,
                         module_project_id: current_module_project.id,
                         coefficient: cmplx.value)

    end
    redirect_to main_app.root_url
  end

  def help
    factor = Factor.find(params[:factor_id])
    @descriptions = factor.organization_uow_complexities.map{|i| ["<strong>#{i.name}</strong>", "#{ i.description.blank? ? 'N/A' : i.description }"]}.join("<br>")
  end
end
