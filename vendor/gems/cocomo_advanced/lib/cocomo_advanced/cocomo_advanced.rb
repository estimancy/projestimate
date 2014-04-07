require 'cocomo_advanced/version'

module CocomoAdvanced

  #Definition of CocomoBasic
  class CocomoAdvanced

    include ApplicationHelper

    attr_accessor :coef_a, :coef_b, :coef_kls, :complexity

    #Constructor
    def initialize(elem)
      elem[:ksloc].blank? ? @coef_kls = nil : @coef_kls = elem[:ksloc].to_f
      case elem[:complexity]
        when 'Organic'
          set_cocomo_organic
        when 'Semi-detached'
          set_cocomo_semidetached
        when 'Embedded'
          set_cocomo_embedded
        else
          set_cocomo_organic
      end
    end

    def set_cocomo_organic
      @coef_a = 3.02
      @coef_b = 1.05
      @complexity = "Organic"
    end

    def set_cocomo_embedded
      @coef_a = 3
      @coef_b = 1.12
      @complexity = "Semi-detached"
    end

    def set_cocomo_semidetached
      @coef_a = 2.8
      @coef_b = 1.2
      @complexity = "Embedded"
    end

    # Return effort
    def get_effort_man_month(*args)
      coeff = Array.new

      Factor.all.each do |factor|
        ic = InputCocomo.where(factor_id: factor.id,
                               pbs_project_element_id: args[2],
                               module_project_id: args[1],
                               project_id: args[0]).first.coefficient

        coeff << ic
      end
      coeff_total = coeff.inject(:*)

      res = (@coef_a * (@coef_kls ** @coef_b)) * coeff_total

      return res
    end
  end

end
