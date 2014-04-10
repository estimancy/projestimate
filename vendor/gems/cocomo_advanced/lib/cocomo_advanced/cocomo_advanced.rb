require 'cocomo_advanced/version'

module CocomoAdvanced

  #Definition of CocomoBasic
  class CocomoAdvanced

    include ApplicationHelper

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_kls, :complexity, :effort

    #Constructor
    def initialize(elem)
      @coef_kls = elem['ksloc'].to_f
      case elem['complexity']
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
      @coef_c = 1.05
      @complexity = "Organic"
    end

    def set_cocomo_embedded
      @coef_a = 3
      @coef_b = 1.12
      @coef_c = 1.20
      @complexity = "Semi-detached"
    end

    def set_cocomo_semidetached
      @coef_a = 2.8
      @coef_b = 1.2
      @coef_c = 1.12
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

      return ((@coef_a * (@coef_kls ** @coef_b)) * coeff_total)
    end

    #Return delay (in hour)
    def get_delay(*args)
      @effort = get_effort_man_month(args[0], args[1], args[2])
      @delay = (2.5*((@effort/152)**@coef_c)).to_f
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

    def get_complexity(*args)
      @complexity
    end

    def get_cost(*args)
      @cost = 0
      @cost
    end
  end

end
