#########################################################################
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2012-2013 Spirula (http://www.spirula.fr)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################

require 'effort_breakdown/version'

module EffortBreakdown

  #Effort Breakdown class
  class EffortBreakdown
    include PemoduleEstimationMethods

    attr_accessor :pbs_project_element, :module_project, :input_effort_person_month #module input/output parameters

    def initialize(module_input_data)
      #puts "INPUT_DATA = #{module_input_data}"   for ex. : INPUT_DATA = {:effort_person_month=>"10", :pbs_project_element_id=>271, :module_project_id=>265}
      @pbs_project_element = PbsProjectElement.find(module_input_data[:pbs_project_element_id])
      @module_project = ModuleProject.find(module_input_data[:module_project_id])
      module_input_data['effort_person_month'].blank? ? @input_effort_person_month = nil : @input_effort_person_month = module_input_data['effort_person_month'].to_f
    end


    # Getters for module outputs

    # Calculate each Wbs activity effort according to Ratio and Reference_Value and PBS effort
    def get_effort_person_month(*args)
      # First build cache_depth
      WbsProjectElement.rebuild_depth_cache!

      #efforts_man_month = nil
      #if @module_project.reference_value.nil?
      #  efforts_man_month = get_efforts_with_one_activity_element
      #else
      #  case @module_project.reference_value.value.to_s
      #    # One Activity-element. defined as the reference
      #    when 'One Activity-element'
      #      efforts_man_month = get_efforts_with_one_activity_element
      #
      #    # A set of Activity-elements defined as reference
      #    when 'A set of activity-elements'
      #      efforts_man_month = get_efforts_with_a_set_of_activity_elements
      #
      #    # All Activity-elements defined as reference
      #    when 'All Activity-elements'
      #      efforts_man_month = get_efforts_with_all_activities_elements
      #
      #    else
      #      efforts_man_month = get_efforts_with_one_activity_element
            efforts_man_month = get_efforts_with_all_activities_elements
      #  end
      #end
      efforts_man_month
    end


    # Get each wbs-activity-element effort with one activity element as reference
    def get_efforts_with_one_activity_element(*args)
      #project on which estimation is
      project = @module_project.project

      # Project pe_wbs_activity
      pe_wbs_activity = @module_project.project.pe_wbs_projects.activities_wbs.first

      # Get the wbs_project_element which contain the wbs_activity_ratio
      project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
      #wbs_project_elt_with_ratio = WbsProjectElement.where("pe_wbs_project_id = ? and wbs_activity_id = ? and is_added_wbs_root = ?", pe_wbs_activity.id, @pbs_project_element.wbs_activity_id, true).first
      # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)
      wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first

      ratio_reference = nil
      # Use project default Ratio, unless PSB got its own Ratio,
      # If default ratio was defined in PBS, it will override the one defined in module-project
      if @pbs_project_element.wbs_activity_ratio.nil?
        ratio_reference = wbs_project_elt_with_ratio.wbs_activity_ratio
      else
        ratio_reference = @pbs_project_element.wbs_activity_ratio
      end

      # Get the referenced wbs_activity_elt of the ratio_reference
      referenced_ratio_element = WbsActivityRatioElement.where('wbs_activity_ratio_id =? and simple_reference = ?', ratio_reference.id, true).first

      # Get the WBS-Project element corresponding to the defined activity as the one reference value
      one_activity_element = referenced_ratio_element.wbs_activity_element
      project_one_activity_element = pe_wbs_activity.wbs_project_elements.where('wbs_activity_element_id = ?', one_activity_element.id).first
      #puts "ONE_ACTIVITY_ELEMENT_ID = #{one_activity_element.id}"
      #puts "project_one_activity_element = #{project_one_activity_element.id}"

      output_effort = Hash.new

      project_wbs_project_elt_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')

        sorted_node_elements.each do |wbs_project_element|
          # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
          unless wbs_project_element.wbs_activity_element.nil?
            # Element effort is really computed only on leaf element
            if wbs_project_element.is_childless? || wbs_project_element.has_new_complement_child?
              # Get the ratio Value of current element
              corresponding_ratio_value = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', ratio_reference.id, wbs_project_element.wbs_activity_element_id).first.ratio_value
              current_output_effort = @input_effort_person_month.nil? ? nil : ((@input_effort_person_month.to_f * corresponding_ratio_value.to_f / 100) * referenced_ratio_element.ratio_value.to_f)
              output_effort[wbs_project_element.id] = current_output_effort
            else
              output_effort[wbs_project_element.id] = compact_array_and_compute_node_value(wbs_project_element, output_effort)
            end
          end
        end
      end

      # Update the one activity element effort
      output_effort[project_one_activity_element.id] = @input_effort_person_month

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      #output_effort[project_wbs_project_elt_root.id] = output_effort.inject(0) {|sum, (key,value)| sum += value}
      output_effort[project_wbs_project_elt_root.id] = compact_array_and_compute_node_value(project_wbs_project_elt_root, output_effort)

      # Global output efforts
      output_effort
    end


    # Get each wbs-activity-element effort with a set of activity elements as references
    def get_efforts_with_a_set_of_activity_elements(*args)

      #project on which estimation is
      project = @module_project.project

      # Project pe_wbs_activity
      pe_wbs_activity = @module_project.project.pe_wbs_projects.activities_wbs.first

      # Get the wbs_project_element which contain the wbs_activity_ratio
      project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
      #wbs_project_elt_with_ratio = WbsProjectElement.where("pe_wbs_project_id = ? and wbs_activity_id = ? and is_added_wbs_root = ?", pe_wbs_activity.id, @pbs_project_element.wbs_activity_id, true).first
      # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)
      wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first

      ratio_reference = nil
      # Use project default Ratio, unless PSB got its own Ratio,
      # If default ratio was defined in PBS, it will override the one defined in module-project
      if @pbs_project_element.wbs_activity_ratio.nil?
        ratio_reference = wbs_project_elt_with_ratio.wbs_activity_ratio
      else
        ratio_reference = @pbs_project_element.wbs_activity_ratio
      end

      #Get the referenced wbs_activity_elt of the ratio_reference
      referenced_ratio_elements = WbsActivityRatioElement.where('wbs_activity_ratio_id =? and multiple_references = ?', ratio_reference.id, true)
      referenced_values_efforts = 0
      referenced_ratio_elements.each do |reference_value|
        referenced_values_efforts = referenced_values_efforts + reference_value.ratio_value.to_f
      end

      output_effort = Hash.new
      project_wbs_project_elt_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')
        sorted_node_elements.each do |wbs_project_element|
          # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
          unless wbs_project_element.wbs_activity_element.nil?
            # Element effort is really computed only on leaf element
            if wbs_project_element.is_childless? || wbs_project_element.has_new_complement_child?
              # Get the ratio Value of current element
              corresponding_ratio_value = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', ratio_reference.id, wbs_project_element.wbs_activity_element_id).first.ratio_value
              current_output_effort = @input_effort_person_month.nil? ? nil : (@input_effort_person_month.to_f * corresponding_ratio_value.to_f / referenced_values_efforts)
              output_effort[wbs_project_element.id] = current_output_effort
            else
              output_effort[wbs_project_element.id] = compact_array_and_compute_node_value(wbs_project_element, output_effort)
            end
          end
        end
      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_effort[project_wbs_project_elt_root.id] = compact_array_and_compute_node_value(project_wbs_project_elt_root, output_effort)

      # Global output efforts
      output_effort
    end


    # Get each wbs-activity-element effort with all activity elements as references
    def get_efforts_with_all_activities_elements(*args)

      #project on which estimation is
      project = @module_project.project

      # Project pe_wbs_activity
      pe_wbs_activity = @module_project.project.pe_wbs_projects.activities_wbs.first

      # Get the wbs_project_element which contain the wbs_activity_ratio
      project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
      # wbs_project_elt_with_ratio = WbsProjectElement.where("pe_wbs_project_id = ? and wbs_activity_id = ? and is_added_wbs_root = ?", pe_wbs_activity.id, @pbs_project_element.wbs_activity_id, true).first
      # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)
      wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first

      ratio_reference = nil
      # Use project default Ratio, unless PSB got its own Ratio,
      # If default ratio was defined in PBS, it will override the one defined in module-project
      if @pbs_project_element.wbs_activity_ratio.nil?
        ratio_reference = wbs_project_elt_with_ratio.wbs_activity_ratio
      else
        ratio_reference = @pbs_project_element.wbs_activity_ratio
      end

      output_effort = Hash.new
      project_wbs_project_elt_root.children.each do |node|
        # Sort node subtree by ancestry_depth
        sorted_node_elements = node.subtree.order('ancestry_depth desc')

        sorted_node_elements.each do |wbs_project_element|
          # A Wbs_project_element is only computed is this module if it has a corresponding Ratio table
          unless wbs_project_element.wbs_activity_element.nil?

            # Element effort is really computed only on leaf element
            if wbs_project_element.is_childless? || wbs_project_element.has_new_complement_child?
              # Get the ratio Value of current element
              corresponding_ratio_value = WbsActivityRatioElement.where('wbs_activity_ratio_id = ? and wbs_activity_element_id = ?', ratio_reference.id, wbs_project_element.wbs_activity_element_id).first.ratio_value
              current_output_effort = @input_effort_person_month.nil? ? nil : (@input_effort_person_month.to_f * corresponding_ratio_value.to_f / 100)
              output_effort[wbs_project_element.id] = current_output_effort
            else
              output_effort[wbs_project_element.id] = compact_array_and_compute_node_value(wbs_project_element, output_effort)
            end
          end
        end
      end

      # After treating all leaf and node elements, the root element is going to compute by aggregation
      output_effort[project_wbs_project_elt_root.id] = compact_array_and_compute_node_value(project_wbs_project_elt_root, output_effort)

      # Global output efforts
      output_effort
    end

    # redefinition of the methods
    # method that compute not leaf node estimation value by aggregation
    def compact_array_and_compute_node_value(node, effort_array)
      tab = []
      node.children.map do |child|
        unless child.wbs_activity_element.nil? || child.wbs_activity.nil?
          value = effort_array[child.id]
          if value.is_a?(Integer) || value.is_a?(Float)
            tab << value
          end
        end
      end

      estimation_value = nil
      unless tab.empty?
        estimation_value = tab.compact.sum
      end

      estimation_value
    end

  end #END CLASS
end #END MODULE
