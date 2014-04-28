require 'cocomo_expert/version'

module CocomoExpert

  #Definition of CocomoBasic
  class CocomoExpert

    attr_accessor :coef_a, :coef_b, :coef_c, :coef_kls, :complexity, :effort

    #Constructor
    def initialize(elem)
      @coef_kls = elem['ksloc'].to_f
    end

    # Return effort
    def get_effort_man_month(*args)
      sf = Array.new
      em = Array.new

      aliass = %w(prec flex resl team pmat)
      aliass.each do |a|
        ic = InputCocomo.where(factor_id: Factor.where(alias: a).first.id,
                               pbs_project_element_id: args[2],
                               module_project_id: args[1],
                               project_id: args[0]).first.coefficient
        sf << ic
      end

      aliass = %w(pers rcpx ruse pdif prex fcil sced)
      aliass.each do |a|
        em << InputCocomo.where( factor_id: Factor.where(alias: a).first.id,
                                 pbs_project_element_id: args[2],
                                 module_project_id: args[1],
                                 project_id: args[0]).first.coefficient
      end

      a = 2.94
      b = 0.91 + 0.01 * sf.sum

      pm = em.sum * a * (0.01 * @coef_kls)**b

      return pm
    end

    #Return delay (in hour)
    def get_delay(*args)
      @effort = get_effort_man_month(args[0], args[1], args[2])

      sf = Array.new
      aliass = %w(prec flex resl team pmat)
      aliass.each do |a|
        ic = InputCocomo.where(factor_id: Factor.where(alias: a).first.id,
                               pbs_project_element_id: args[2],
                               module_project_id: args[1],
                               project_id: args[0]).first.coefficient
        sf << ic
      end

      f = 0.28 + 0.2 * (1/100) * sf.sum
      @delay = 3.76 * (@effort ** f)
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
