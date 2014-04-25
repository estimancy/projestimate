require 'uos/version'

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
      Input.where(:module_project_id => args[1], pbs_project_element_id: args[2]).first.gross_low
    end

  end

end
