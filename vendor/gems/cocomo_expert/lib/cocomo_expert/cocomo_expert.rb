require 'cocomo_expert/version'

module CocomoExpert

  #Definition of CocomoBasic
  class CocomoExpert

    include ApplicationHelper

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_kls, :complexity, :effort

    #Constructor
    def initialize(elem)
      @coef_kls = elem['ksloc'].to_f
    end

    # Return effort
    def get_effort_man_month(*args)
      coeff = Array.new
      Factor.where(factor_type: "early_design").all.each do |factor|

        ic = InputCocomo.where(factor_id: factor.id,
                               pbs_project_element_id: args[2],
                               module_project_id: args[1],
                               project_id: args[0]).first.coefficient
        coeff << ic
      end


      pers = InputCocomo.where( factor_id: Factor.where(alias: "pers").first.id,
                                pbs_project_element_id: args[2],
                                module_project_id: args[1],
                                project_id: args[0]).first.coefficient

      rcpx = InputCocomo.where( factor_id: Factor.where(alias: "rcpx").first.id,
                                pbs_project_element_id: args[2],
                                module_project_id: args[1],
                                project_id: args[0]).first.coefficient

      ruse = InputCocomo.where( factor_id: Factor.where(alias: "ruse").first.id,
                                pbs_project_element_id: args[2],
                                module_project_id: args[1],
                                project_id: args[0]).first.coefficient

      pdif = InputCocomo.where( factor_id: Factor.where(alias: "pdif").first.id,
                                pbs_project_element_id: args[2],
                                module_project_id: args[1],
                                project_id: args[0]).first.coefficient

      prex = InputCocomo.where( factor_id: Factor.where(alias: "prex").first.id,
                                pbs_project_element_id: args[2],
                                module_project_id: args[1],
                                project_id: args[0]).first.coefficient

      fcil = InputCocomo.where( factor_id: Factor.where(alias: "fcil").first.id,
                                pbs_project_element_id: args[2],
                                module_project_id: args[1],
                                project_id: args[0]).first.coefficient

      sced = InputCocomo.where( factor_id: Factor.where(alias: "sced").first.id,
                                pbs_project_element_id: args[2],
                                module_project_id: args[1],
                                project_id: args[0]).first.coefficient

      a = 2.94
      em = pers + rcpx + ruse + pdif + prex + fcil + sced
      b = 0.91 + (1/100) * coeff.sum
      pm = em * a * @coef_kls**b

      pm
    end

    #Return delay (in hour)
    def get_delay(*args)
      @effort = get_effort_man_month(args[0], args[1], args[2])
      @delay = 1
      #@delay = (2.5*((@effort/152)**@coef_c)).to_f
      @delay
    end

    #Return end date
    def get_end_date(*args)
      @end_date = (Time.now + (get_delay(args[0], args[1], args[2])).to_i.months)
      @end_date
    end

    #Return staffing
    def get_staffing(*args)
      @staffing = (get_effort_man_month(args[0], args[1], args[2]) / get_delay(args[0], args[1], args[2]))
      @staffing
    end

    def get_cost(*args)
      @cost = 0
      @cost
    end
  end

end
