require 'cocomo_advanced/version'

module CocomoAdvanced

  #Definition of CocomoBasic
  class CocomoAdvanced

    include ApplicationHelper

    attr_accessor :coef_a, :coef_b, :coef_kls, :complexity

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

      res = (@coef_a * (@coef_kls ** @coef_b))# * coeff_total

      return res
    end

    #Return delay (in hour)
    def get_delay(*args)
      #if @coef_kls && @complexity
      @delay = 0
      #else
      #  nil
      #end

      #return @delay
    end

    #Return end date
    def get_end_date(*args)
      #if @coef_kls && @complexity
      @end_date = 0
      #else
      #  nil
      #end

      #return @end_date
    end

    #Return staffing
    def get_staffing(*args)
      #if @coef_kls && @complexity
      @staffing = 0
      #else
      #  nil
      #end

      #return @staffing
    end

    def get_cost(*args)
      @cost = 0
    end

    def get_complexity(*args)
      #if @complexity
      @complexity
      #else
      #  nil
      #end
    end
  end

end
