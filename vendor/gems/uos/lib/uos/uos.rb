require 'cocomo_advanced/version'

module Uos

  #Definition of Uo
  class Uos

    include ApplicationHelper

    attr_accessor :size

    #Constructor
    def initialize(elem)
      @size = elem['size']
    end

    # Return effort
    #project.id, current_mp_to_execute.id, pbs_project_element_id)
    def get_effort_man_hour(*args)
      #EstimationValue.where(:module_project_id => args[1]).first.gross_low
      1212
    end
  end

end
