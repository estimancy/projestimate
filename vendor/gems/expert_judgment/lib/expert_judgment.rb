require 'expert_judgment/version'

module ExpertJudgment

  # Expert Judgment gem definition
  class ExpertJudgment
    include PemoduleEstimationMethods

    attr_accessor :effort_man_hour, :minimum, :most_likely, :maximum, :probable, :pbs_project_element_id, :wbs_project_element_root

    def initialize(elem)
      WbsProjectElement.rebuild_depth_cache!
      ###elem[:effort_man_hour].blank? ? @effort_man_hour = nil : @effort_man_hour = elem[:effort_man_hour]
      @effort_man_hour = elem[:effort_man_hour]


      ##is_integer_or_float?(elem[:effort_man_hour]) ? @effort_man_hour = elem[:effort_man_hour] : @effort_man_hour = nil

      set_minimum(elem)
      set_maximum(elem)
      set_most_likely(elem)
      set_wbs_project_element_root(elem)
    end

    def is_integer_or_float?(value)
      if value.is_a?(Integer) || value.is_a?(Float)
        true
      else
        false
      end
    end

    def set_minimum(elem)
      elem[:minimum].nil? ? @minimum = 0 : @minimum = elem[:minimum].to_f
    end

    def set_maximum(elem)
      elem[:maximum].nil? ? @maximum = 0 : @maximum = elem[:maximum].to_f
    end

    def set_most_likely(elem)
      elem[:most_likely].nil? ? @most_likely = 0 : @most_likely = elem[:most_likely].to_f
    end

    def set_probable
      ( (@minimum + (4*@most_likely) + @maximum) / 6 )
    end

    #Set the WBS-activity node elements effort using aggregation (sum) of child elements (from the bottom up)
    def set_node_effort_man_hour(node)
    end

    #Get the project WBS root
    def set_wbs_project_element_root(elem)
      @pbs_project_element = PbsProjectElement.find(elem[:pbs_project_element_id])
      current_project = @pbs_project_element.pe_wbs_project.project
      pe_wbs_project_activity = current_project.pe_wbs_projects.wbs_activity.first
      @wbs_project_element_root = pe_wbs_project_activity.wbs_project_elements.where("is_root = ?", true).first
    end

    #GETTERS
    def get_effort_man_hour
      new_effort_man_hour = Hash.new
      root_element_effort_man_hour = 0.0

      @wbs_project_element_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')
        sorted_node_elements.each do |wbs_project_element|
          if wbs_project_element.is_childless?
            ###new_effort_man_hour[wbs_project_element.id] = (@effort_man_hour[wbs_project_element.id.to_s].blank? ? 0 : @effort_man_hour[wbs_project_element.id.to_s].to_f)
            new_effort_man_hour[wbs_project_element.id] = (is_integer_or_float?(@effort_man_hour[wbs_project_element.id.to_s]) ? @effort_man_hour[wbs_project_element.id.to_s].to_f : nil)
            #if is_integer_or_float?(@effort_man_hour[wbs_project_element.id.to_s])
            #  new_effort_man_hour[wbs_project_element.id] = @effort_man_hour[wbs_project_element.id.to_s].to_f
            #else
            #  new_effort_man_hour[wbs_project_element.id] = nil
            #end
          else
            node_effort = 0.0
            wbs_project_element.children.each do |child|
              node_effort = node_effort + new_effort_man_hour[child.id].to_f
            end
            ### TODO: REMOVE THIS LINE AFTER    new_effort_man_hour[wbs_project_element.id] = node_effort
            new_effort_man_hour[wbs_project_element.id] = compact_array_and_compute_node_value(wbs_project_element, new_effort_man_hour)
          end
        end

        #compute the wbs root effort
        ##root_element_effort_man_hour = root_element_effort_man_hour + new_effort_man_hour[node.id]
      end

      ##TODO(REMOVE) new_effort_man_hour[@wbs_project_element_root.id] = root_element_effort_man_hour
      new_effort_man_hour[@wbs_project_element_root.id] = compact_array_and_compute_node_value(@wbs_project_element_root, new_effort_man_hour)

      new_effort_man_hour
    end

  end

end
