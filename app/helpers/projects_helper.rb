#encoding: utf-8
##########################################################################
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


module ProjectsHelper

  # This helper method will display Estimation Result according the estimation purpose (PBS and/or Activities)
  def display_results
    res = String.new
    unless current_project.nil?
      pbs_project_element = @pbs_project_element || current_project.root_component
      #get the current module_project
      module_project_to_display = current_module_project

      if module_project_to_display.pemodule.yes_for_output_with_ratio? || module_project_to_display.pemodule.yes_for_output_without_ratio? || module_project_to_display.pemodule.yes_for_input_output_with_ratio? || module_project_to_display.pemodule.yes_for_input_output_without_ratio?
        if module_project_to_display.pemodule.alias == 'effort_balancing'
          res << display_effort_balancing_output(module_project_to_display)
        else
          res << display_results_with_activities(module_project_to_display)
        end
      else
        res << display_results_without_activities(module_project_to_display)
      end
      res
    end
    res
  end

  # Methdods that display estimation results
  def display_results_without_activities(module_project)
    res = String.new
    pbs_project_element = @pbs_project_element || current_project.root_component

    pemodule = Pemodule.find(module_project.pemodule.id)
    res << "<h4>#{ I18n.t(:label_output_data) }</h4>"
    res << "<table class='table table-condensed table-bordered'>
                 <tr>
                   <th></th>"
    ['low', 'most_likely', 'high', 'probable'].each do |level|
      res << "<th>#{level.humanize}</th>"
    end
    res << '</tr>'

    module_project.estimation_values.where('in_out = ?', 'output').order('display_order ASC').each do |est_val|
      est_val_pe_attribute = est_val.pe_attribute
      res << "<tr><td><span class='attribute_tooltip tree_element_in_out' title='#{est_val_pe_attribute.description} #{display_rule(est_val)}'>#{est_val_pe_attribute.name}</span></td>"

      ['low', 'most_likely', 'high', 'probable'].each do |level|
        res << '<td>'
        level_estimation_values = Hash.new
        level_estimation_values = est_val.send("string_data_#{level}")
        if level_estimation_values.nil? || level_estimation_values[pbs_project_element.id].nil? || level_estimation_values[pbs_project_element.id].blank?
          res << '-'
        else
          res << "#{display_value(level_estimation_values[pbs_project_element.id], est_val)}"
        end
        res << '</td>'
      end
      res << '</tr>'
    end

    res << '</table>'

    res
  end


  #The view to display result with ACTIVITIES
  def display_results_with_activities(module_project)
    res = String.new
    pbs_project_element = @pbs_project_element || current_project.root_component

    pe_wbs_activity = module_project.project.pe_wbs_projects.activities_wbs.first
    project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first

    pemodule = Pemodule.find(module_project.pemodule.id)
    res << " <h4>#{ I18n.t(:label_output_data) }</h4> "
    res << " <table class='table table-condensed table-bordered'>
               <tr>
                 <th></th>"

    # Get the module_project probable estimation values for showing element consistency
    probable_est_value_for_consistency = nil
    pbs_level_data_for_consistency = Hash.new

    module_project.estimation_values.order('display_order ASC').each do |est_val|
      if (est_val.in_out == 'output' or est_val.in_out=='both') and est_val.module_project.id == module_project.id
        probable_est_value_for_consistency = est_val.send("string_data_probable")
        res << "<th colspan='4'><span class='attribute_tooltip' title='#{est_val.pe_attribute.description} #{display_rule(est_val)}'>#{est_val.pe_attribute.name}</span></th>"

        # For is_consistent purpose
        ['low', 'most_likely', 'high', 'probable'].each do |level|
          unless level.eql?("probable")
            pbs_data_level = est_val.send("string_data_#{level}")
            pbs_data_level.nil? ? pbs_level_data_for_consistency[level] = nil : pbs_level_data_for_consistency[level] = pbs_data_level[pbs_project_element.id]
          end
        end
      end
    end
    res << '</tr>'

    # We are showing for each PBS and/or ACTIVITY the (low, most_likely, high) values
    res << '<tr>
              <th></th>'
    ['low', 'most_likely', 'high', 'probable'].each do |level|
      res << "<th>#{level.humanize}</th>"
    end
    res << '</tr>'

    module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.each do |wbs_project_elt|

      pbs_probable_for_consistency = probable_est_value_for_consistency.nil? ? nil : probable_est_value_for_consistency[pbs_project_element.id]
      wbs_project_elt_consistency = (pbs_probable_for_consistency.nil? || pbs_probable_for_consistency[wbs_project_elt.id].nil?) ? false : pbs_probable_for_consistency[wbs_project_elt.id][:is_consistent]
      show_consistency_class = nil
      unless wbs_project_elt_consistency || module_project.pemodule.alias == "effort_breakdown"
        show_consistency_class = "<span class='icon-warning-sign not_consistent attribute_tooltip' title='<strong>#{I18n.t(:warning_caution)}</strong> </br>  #{I18n.t(:warning_wbs_not_complete, :value => wbs_project_elt.name)}'></span>"
      end

      #For wbs-activity-completion node consistency
      completion_consistency = ""
      title = ""
      if module_project.pemodule.alias == "wbs_activity_completion"
        current_wbs_consistency = true
        pbs_level_data_for_consistency.each do |level, level_value|
          #if !pbs_level_data_for_consistency.nil?
          if !level_value.nil? && !level_value.empty?
            wbs_level_data = level_value[wbs_project_elt.id]
            wbs_level_data.nil? ? current_wbs_consistency_level = nil : current_wbs_consistency_level = wbs_level_data[:is_consistent]
            current_wbs_consistency = current_wbs_consistency && current_wbs_consistency_level
            if !!current_wbs_consistency == false
              if show_consistency_class.nil?
                completion_consistency = "icon-warning-sign not_consistent attribute_tooltip"
                title = I18n.t(:warning_caution) + " : " + I18n.t(:warning_wbs_not_consistent)
              else
                show_consistency_class = "<span class='icon-warning-sign not_consistent attribute_tooltip' title=' <strong>#{I18n.t(:warning_caution)}</strong> </br> * #{I18n.t(:warning_wbs_not_complete, :value => wbs_project_elt.name)} </br> * #{I18n.t(:warning_wbs_not_consistent)}'></span>"
              end

              break
            end
          end
        end
      end

      res << "<tr> <td> <span class='tree_element_in_out  #{completion_consistency}' title='#{title}' style='margin-left:#{wbs_project_elt.depth}em;'> #{show_consistency_class}  #{wbs_project_elt.name} </span> </td>"

      ['low', 'most_likely', 'high', 'probable'].each do |level|
        res << '<td>'
        module_project.estimation_values.where('in_out = ?', 'output').each do |est_val|
          if (est_val.in_out == 'output' or est_val.in_out=='both') and est_val.module_project.id == module_project.id
            level_estimation_values = Hash.new
            level_estimation_values = est_val.send("string_data_#{level}")
            if level_estimation_values.nil? || level_estimation_values[pbs_project_element.id].nil? || level_estimation_values[pbs_project_element.id][wbs_project_elt.id].nil? || level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value].nil?
              res << ' - '
            else
              res << "#{display_value(level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value], est_val)}"
            end
          end
        end
        res << '</td>'
      end
      res << '</tr>'
    end

    #Show the global result of the PBS
    res << '<tr>
              <td><strong>  </strong></td>'
    ['low', 'most_likely', 'high', 'probable'].each do |level|
      res << '<td></td>'
    end
    res << '</tr>'

    # Show the probable values
    res << "<tr><td><strong> #{pbs_project_element.name} Probable Value </strong> </td>"
    module_project.estimation_values.each do |est_val|
      if (est_val.in_out == 'output' or est_val.in_out=='both') and est_val.module_project_id == module_project.id
        res << "<td colspan='3'>"
        level_probable_value = est_val.send('string_data_probable')
        if level_probable_value.nil? || level_probable_value[pbs_project_element.id].nil? || level_probable_value[pbs_project_element.id][project_wbs_project_elt_root.id].nil? || level_probable_value[pbs_project_element.id][project_wbs_project_elt_root.id][:value].nil?
          res << '-'
        else
          res << "<div align='center'>#{display_value(level_probable_value[pbs_project_element.id][project_wbs_project_elt_root.id][:value], est_val)}</div>"
        end
        res << '</td>'
        res << '<td></td>'
      end
    end
    res << '</tr>'
    res << '</table>'

    res
  end

  def display_effort_balancing_output(module_project)
    pbs_project_element = @pbs_project_element || current_project.root_component
    res = String.new
    if module_project.compatible_with(current_component.work_element_type.alias) || current_component
      pemodule = Pemodule.find(module_project.pemodule.id)
      res << "<h4>#{ I18n.t(:label_output_data) }</h4>"
      res << "<table class='table table-condensed table-bordered'>"

      res << '<tr>
                <th></th>'
      module_project.estimation_values.each do |est_val|
        if (est_val.in_out == 'output' or est_val.in_out=='both') and est_val.module_project.id == module_project.id
          res << "<th><span class='attribute_tooltip' title='#{est_val.pe_attribute.description} #{display_rule(est_val)}' rel='tooltip'>#{est_val.pe_attribute.name}</span></th>"
        end
      end

      res << '</tr>'

      module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.each do |wbs_project_elt|
        res << "<tr>
                    <td>
                      <span class='tree_element_in_out' style='margin-left:#{wbs_project_elt.depth}em;'>#{wbs_project_elt.name}</span></td>"
        res << '</td>'
        module_project.estimation_values.select { |i| i.in_out == 'output' or i.in_out=='both' }.each do |est_val|
          level_estimation_values = Hash.new
          level_estimation_values = est_val.send("string_data_probable")

          res << '<td>'
          if level_estimation_values and level_estimation_values[pbs_project_element.id]
            if level_estimation_values[pbs_project_element.id] and level_estimation_values[pbs_project_element.id][wbs_project_elt.id].blank?
              res << "#{level_estimation_values[pbs_project_element.id][wbs_project_elt.id]}"
            else
              if est_val.pe_attribute.attribute_type == "numeric"
                res << "#{level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value]}"
              else
                res << "#{level_estimation_values[pbs_project_element.id][wbs_project_elt.id]}"
              end
            end
          else
            res << "-"
          end
          res << '</td>'
        end
        res << '</tr>'
      end
      res << '</table>'
    end
  end

  # Display Estimations output results according to the module behavior
  def display_input
    res = String.new
    unless current_project.nil?
      pbs_project_element = @pbs_project_element || current_project.root_component

      current_project = current_module_project.project
      current_module_project_pemodule = current_module_project.pemodule

      ##if module_project.pemodule.with_activities
      if current_module_project_pemodule.yes_for_input? || current_module_project_pemodule.yes_for_input_output_without_ratio? || current_module_project_pemodule.yes_for_input_output_with_ratio?

        # For WBS-ACTIVITY-COMPLETION MODULE
        if current_module_project_pemodule.alias == "wbs_activity_completion"
          @defined_status = RecordStatus.find_by_name("Defined")
          last_estimation_result = nil
          effort_breakdown_module = Pemodule.where("alias = ? AND record_status_id = ?", "effort_breakdown", @defined_status.id).first

          unless effort_breakdown_module.nil?
            refer_module_potential_ids = module_project.associated_module_projects ###+ module_project.inverse_associated_module_projects
                                                                                   #unless refer_module.empty?
            refer_attribute = PeAttribute.where("alias = ? AND record_status_id = ?", "effort_man_hour", @defined_status.id).first
            #refer_attribute = PeAttribute.where("alias = ? AND record_status_id = ?", "effort_man_month", @defined_status.id).first

            refer_modules_project = ModuleProject.joins(:project, :pbs_project_elements).where("pemodule_id = ? AND  project_id =? AND pbs_project_elements.id = ?", effort_breakdown_module.id, current_project.id, pbs_project_element.id)
            refer_module_project = refer_modules_project.where(["module_project_id IN (?)", refer_module_potential_ids]).last

            unless refer_module_project.nil?
              # Get the estimation_value corresponding to the linked Effort_breakdown module (if there is one)
              last_estimation_results = EstimationValue.where('in_out = ? AND pe_attribute_id = ? AND module_project_id = ?', 'output', refer_attribute.id, refer_module_project.id).first

              if last_estimation_results.nil?
                last_estimation_result = Hash.new
              else
                last_estimation_result = last_estimation_results

                pe_wbs_project_activity = current_project.pe_wbs_projects.activities_wbs.first
                project_wbs_root = pe_wbs_project_activity.wbs_project_elements.where("is_added_wbs_root = ?", true).first

                # Get all complement children
                complement_children_ids = project_wbs_root.get_all_complement_children

                # This will be completed only if WBS has one or more not coming from library
                unless complement_children_ids.empty?
                  current_mp_est_value = current_module_project.estimation_values.where("pe_attribute_id = ? AND in_out = ?", refer_attribute.id, "output").last
                  ##new_created_estimation_value = EstimationValue.new
                  new_created_estimation_value = last_estimation_results

                  ['low', 'most_likely', 'high'].each do |level|

                    new_created_estimation_value_level = new_created_estimation_value.send("string_data_#{level}")

                    level_current_mp_est_val = current_mp_est_value.send("string_data_#{level}")

                    if !level_current_mp_est_val.nil? || !level_current_mp_est_val.empty?

                      pbs_level_value = level_current_mp_est_val[pbs_project_element.id]

                      unless pbs_level_value.nil?
                        complement_children_ids.each do |complement_child_id|
                          #new_created_estimation_value_level[pbs_project_element.id] << complement_child_id
                          if !pbs_level_value[complement_child_id].nil? && !level_current_mp_est_val[pbs_project_element.id][complement_child_id].nil?
                            new_created_estimation_value_level[pbs_project_element.id][complement_child_id] = {:value => level_current_mp_est_val[pbs_project_element.id][complement_child_id][:value]}
                          end
                        end
                        new_created_estimation_value.send("string_data_#{level}=".to_sym, new_created_estimation_value_level)
                      end
                    end

                  end
                  last_estimation_result = new_created_estimation_value
                end
              end
            end
          end
          res << display_inputs_with_activities(current_module_project, last_estimation_result)

          # For Effort balancing module
        elsif current_module_project_pemodule.alias == 'effort_balancing'
          res << display_effort_balancing_input(current_module_project, last_estimation_result)
          # For others module with Activities
        else
          res << display_inputs_with_activities(current_module_project)
        end
        # For others modules that don't use WSB-Activities values in input
      elsif current_module_project_pemodule.no? || current_module_project_pemodule.yes_for_output_with_ratio? || current_module_project_pemodule.yes_for_output_without_ratio?
        res << display_inputs_without_activities(current_module_project)
      end
    end
    res
  end

  #Display the Effort Balancing Input
  def display_effort_balancing_input(module_project, last_estimation_result)
    pbs_project_element = @pbs_project_element || current_project.root_component
    res = String.new
    if module_project.compatible_with(current_component.work_element_type.alias) || current_component
      pemodule = Pemodule.find(module_project.pemodule.id)
      res << "<h4>#{ I18n.t(:label_input_data) }</h4>"
      res << "<table class='table table-condensed table-bordered'>"

      res << '<tr>
                <th></th>'
      module_project.previous.each_with_index do |est, i|
        res << "<th>#{display_path([], module_project, i).reverse.join('<br>')}</th>"
      end
      module_project.estimation_values.each do |est_val|
        if (est_val.in_out == 'input' or est_val.in_out=='both') and est_val.module_project.id == module_project.id
          res << "<th><span class='attribute_tooltip' title='#{est_val.pe_attribute.description} #{display_rule(est_val)}' rel='tooltip'>#{est_val.pe_attribute.name}</span></th>"
        end
      end

      res << '</tr>'

      module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.each do |wbs_project_elt|
        res << "<tr>
                    <td>
                      <span class='tree_element_in_out' style='margin-left:#{wbs_project_elt.depth}em;'>#{wbs_project_elt.name}</span></td>"
        res << '</td>'
        module_project.previous.each do |mp|
          level = "probable"
          #value of output attributes of previous pemodule_projects
          mp.estimation_values.select { |i| i.in_out == 'output' }.each do |est_val|
            level_estimation_values = Hash.new
            level_estimation_values = est_val.send("string_data_probable")

            res << '<td>'
            if level_estimation_values[pbs_project_element.id]
              begin
                res << text_field_tag("", level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value],
                                      :readonly => true, :class => "input-small #{level} #{est_val.id}",
                                      "data-est_val_id" => est_val.id)
              rescue
                res << text_field_tag("", level_estimation_values[pbs_project_element.id],
                                      :readonly => true, :class => "input-small #{level} #{est_val.id}",
                                      "data-est_val_id" => est_val.id)
              end
            else
              res << '-'
            end
            res << '</td>'
          end
        end

        module_project.estimation_values.select { |i| i.in_out == 'output' }.each do |est_val|
          res << '<td>'
          level_estimation_values = Hash.new
          level_estimation_values = est_val.send("string_data_most_likely")

          if level_estimation_values[pbs_project_element.id].nil? or level_estimation_values[pbs_project_element.id][wbs_project_elt.id].blank?
            res << "#{text_field_tag "[#{est_val.pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                     nil,
                                     :class => "input-small #{est_val.id}",
                                     "data-est_val_id" => est_val.id}"
          else
            res << "#{text_field_tag "[#{est_val.pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                     level_estimation_values[pbs_project_element.id][wbs_project_elt.id][:value],
                                     :class => "input-small #{est_val.id}",
                                     "data-est_val_id" => est_val.id}"
          end
          res << '</td>'
        end
        res << '</tr>'
      end
      res << '</table>'
    end

  end


  #Display the Effort Balancing Output
  def display_inputs_with_activities(module_project, last_estimation_result=nil)
    pbs_project_element = @pbs_project_element || current_project.root_component
    res = String.new
    if module_proxject.compatible_with(current_component.work_element_type.alias) || current_component
      pemodule = Pemodule.find(module_project.pemodule.id)
      res << "<h4>#{ I18n.t(:label_input_data)}</h4>"
      res << "<table class='table table-condensed table-bordered'>"
      res << '<tr>
                <th></th>'
      module_project.estimation_values.order('display_order ASC').each do |est_val|
        est_val_pe_attribute = est_val.pe_attribute
        est_val_in_out = est_val.in_out
        if (est_val_in_out == 'output' or est_val_in_out=='both') and est_val.module_project.id == module_project.id
          res << "<th colspan=4><span class='attribute_tooltip' title='#{est_val_pe_attribute.description} #{display_rule(est_val)}' rel='tooltip'>#{est_val_pe_attribute.name}</span></th>"
        end
      end
      res << '</tr>'

      res << '<tr>
                <th></th>'
      ['low', '', 'most_likely', 'high'].each do |level|
        res << "<th>#{level.humanize}</th>"
      end
      res << '</tr>'

      module_project.project.pe_wbs_projects.activities_wbs.first.wbs_project_elements.each do |wbs_project_elt|
        pe_attribute_alias = nil
        level_parameter = ''
        readonly_option = false
        res << "<tr><td><span class='tree_element_in_out' style='margin-left:#{wbs_project_elt.depth}em;'>#{wbs_project_elt.name}</span></td>" ###res << "<tr><td>#{wbs_project_elt.name}</td>"

        ['low', 'most_likely', 'high'].each do |level|
          res << '<td>'
          module_project.estimation_values.where('in_out = ?', 'input').each do |est_val|
            est_val_pe_attribute = est_val.pe_attribute
            est_val_in_out = est_val.in_out
            if (est_val_in_out == 'input' and est_val.module_project.id == module_project.id)
              level_estimation_values = nil
              level_estimation_values = est_val.send("string_data_#{level}")

              # For Wbs_Activity Complemention module, input data are from last executed module
              if module_project.pemodule.alias == 'wbs_activity_completion'
                pbs_last_result = nil
                unless last_estimation_result.nil? || last_estimation_result.empty?
                  level_last_result = last_estimation_result.send("string_data_#{level}")
                  pbs_last_result = level_last_result[pbs_project_element.id]
                end

                if pbs_last_result.nil?
                  res << "#{text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                           nil,
                                           :class => "input-small #{level} #{est_val.id} #{wbs_project_elt.id}",
                                           "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id}"

                elsif wbs_project_elt.wbs_activity_element.nil?
                  if wbs_project_elt.is_root? || wbs_project_elt.has_children?
                    res << "#{text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                             pbs_last_result[wbs_project_elt.id][:value],
                                             :readonly => true, :class => "input-small #{level} #{est_val.id} #{wbs_project_elt.id}",
                                             "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id}"
                    readonly_option = true
                  else
                    # If element is not from library
                    res << "#{text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                             pbs_last_result[wbs_project_elt.id].nil? ? nil : pbs_last_result[wbs_project_elt.id][:value],
                                             :class => "input-small #{level} #{est_val.id} #{wbs_project_elt.id}",
                                             "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id}"
                  end
                else
                  res << "#{text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                           pbs_last_result[wbs_project_elt.id][:value],
                                           :readonly => true, :class => "input-small #{level} #{est_val.id} #{wbs_project_elt.id}",
                                           "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id}"
                  readonly_option = true
                end
              else
                readonly_option = wbs_project_elt.has_children? ? true : false
                nullity_condition = (level_estimation_values.nil? or level_estimation_values[pbs_project_element.id].nil? or level_estimation_values[pbs_project_element.id][wbs_project_elt.id].nil?)

                if wbs_project_elt.is_root? || wbs_project_elt.has_children?
                  res << "#{ text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                            nullity_condition ? nil : level_estimation_values[pbs_project_element.id][wbs_project_elt.id],
                                            :readonly => readonly_option, :class => "input-small #{level}  #{est_val.id} #{wbs_project_elt.id}",
                                            "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id }"
                else
                  res << "#{ text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id.to_s}][#{wbs_project_elt.id.to_s}]",
                                            nullity_condition ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id][wbs_project_elt.id],
                                            :readonly => readonly_option, :class => "input-small #{level}  #{est_val.id} #{wbs_project_elt.id}",
                                            "data-est_val_id" => est_val.id, "data-wbs_project_elt_id" => wbs_project_elt.id }"
                end
              end

            end
            pe_attribute_alias = est_val_pe_attribute.alias
          end
          res << '</td>'

          if level == 'low'
            #Available to copy value
            input_id = "_#{pe_attribute_alias}_#{module_project.id}_#{wbs_project_elt.id}"
            res << '<td>'
            unless readonly_option
              res << "<span id='#{input_id}' class='copyLib icon  icon-chevron-right' data-effort_input_id='#{input_id}' title='Copy value in other fields' onblur='this.style.cursor='default''></span>"
            end
            res << '</td>'
          end
        end
        res << '</tr>'
      end
      res << '</table>'
    end
    res
  end


  # Display th inputs parameters view
  def display_inputs_without_activities(module_project)
    pbs_project_element = @pbs_project_element || current_project.root_component
    res = String.new

    #if module_project.pemodule.alias == "uos"
    #  display_uos_module(module_project.id)
    #elsif module_project.pemodule.alias == "cocomo_advanced"
    #  link_to "Cocomo Advanced", "/cocomo_advanced"
    #else
      if module_project.compatible_with(current_component.work_element_type.alias) || current_component
        pemodule = Pemodule.find(module_project.pemodule.id)
        res << "<h4>#{ I18n.t(:label_input_data) }</h4>"
        res << "<table class='table table-condensed table-bordered'>
                        <tr>
                          <th></th>"
        ['low', '', 'most_likely', 'high'].each do |level|
          res << "<th>#{level.humanize}</th>"
        end
        res << '</tr>'
        module_project.estimation_values.order('display_order ASC').each do |est_val|
          est_val_pe_attribute = est_val.pe_attribute
          est_val_in_out = est_val.in_out
          if (est_val_in_out == 'input' or est_val_in_out == 'both') and (est_val.module_project.id == module_project.id) and est_val_pe_attribute
            res << '<tr>'
            res << "<td><span class='attribute_tooltip tree_element_in_out' title='#{est_val_pe_attribute.description} #{display_rule(est_val)}'>#{est_val_pe_attribute.name}</span></td>"
            level_estimation_values = Hash.new
            ['low', 'most_likely', 'high'].each do |level|
              level_estimation_values = est_val.send("string_data_#{level}")
              res << "<td>#{pemodule_input(level, est_val, module_project, level_estimation_values, pbs_project_element)}</td>"
              if level == 'low'
                input_id = "_#{est_val_pe_attribute.alias}_#{module_project.id}"
                res << '<td>'
                res << "<span id='#{input_id}' class='copyLib icon  icon-chevron-right' data-effort_input_id='#{input_id}' title='Copy value in other fields' onblur='this.style.cursor='default''></span>"
                res << '</td>'
              end
            end
          end
          res << '</tr>'
        end
        res << '</table>'

        if module_project.pemodule.alias == "uos"
          res << "#{ link_to 'Unit of Works Setting', '/uos?mp=' + module_project.id.to_s }"
        elsif module_project.pemodule.alias == "cocomo_advanced" or module_project.pemodule.alias == "cocomo_expert"
          ic = InputCocomo.where(pbs_project_element_id: pbs_project_element.id,
                                 module_project_id: module_project.id,
                                 project_id: current_project.id).first

          if ic.nil?
            res << link_to("Configure Cocomo's setting", "/#{module_project.pemodule.alias}")
          else
            res << link_to("Reconfigure Cocomo's setting", "/#{module_project.pemodule.alias}")
          end
        else
          ""
        end
      end
      res
    #end
  end


  def pemodule_input(level, est_val, module_project, level_estimation_values, pbs_project_element)

    est_val_pe_attribute = est_val.pe_attribute

    if est_val_pe_attribute.attr_type == 'integer' or est_val_pe_attribute.attr_type == 'float'

      display_text_field_tag(level, est_val, module_project, level_estimation_values, pbs_project_element)

    elsif est_val_pe_attribute.attr_type == 'list'

      select_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                 options_for_select(
                     est_val_pe_attribute.options[2].split(';'),
                     :selected => (level_estimation_values[pbs_project_element.id].nil? ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id])),
                 :class => "input-small #{level} #{est_val.id}",
                 :prompt => "Unset",
                 "data-est_val_id" => est_val.id

    elsif est_val_pe_attribute.attr_type == 'date'

      text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                     level_estimation_values[pbs_project_element.id].nil? ? display_date(level_estimation_values["default_#{level}".to_sym]) : display_date(level_estimation_values[pbs_project_element.id]),
                     :class => "input-small #{level} #{est_val.id} date-picker",
                     "data-est_val_id" => est_val.id

    else #type = text

      text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                     (level_estimation_values[pbs_project_element.id].nil?) ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id],
                     :class => "input-small #{level} #{est_val.id}",
                     "data-est_val_id" => est_val.id
    end
  end


  #Display pemodule output depending attribute type.
  def display_value(value, estimation_value)
    est_val_pe_attribute = estimation_value.pe_attribute
    case est_val_pe_attribute.attr_type
      when 'date'
        display_date(value)
      when 'float'
        begin
          if est_val_pe_attribute.precision
            value.round(est_val_pe_attribute.precision)
          else
            value.round(2)
          end
        rescue
          value
        end
      when 'integer'
        begin
          value.to_i
        rescue
          value
        end
      else
        begin
          value.round(2)
        rescue
          value
        end
    end
  end

  #Display a date depending user time zone
  def display_date(date)
    begin
      I18n.l(date.to_date)
    rescue
      nil
    end
  end

  #Display text field tag depending of estimation plan.
  #Some pemodules can take previous and computed values
  def display_text_field_tag(level, est_val, module_project, level_estimation_values, pbs_project_element)

    est_val_pe_attribute = est_val.pe_attribute

    if module_project.previous.empty? || !est_val["string_data_#{level}"][pbs_project_element.id].nil?
      text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                     level_estimation_values[pbs_project_element.id].nil? ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id].round(2),
                     :class => "input-small #{level} #{est_val.id}",
                     "data-est_val_id" => est_val.id
    else
      comm_attr = ModuleProject::common_attributes(module_project.previous.first, module_project)
      if comm_attr.empty?
        text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                       level_estimation_values[pbs_project_element.id].nil? ? level_estimation_values["default_#{level}".to_sym] : level_estimation_values[pbs_project_element.id],
                       :class => "input-small #{level} #{est_val.id}",
                       "data-est_val_id" => est_val.id
      else
        estimation_value = EstimationValue.where(:pe_attribute_id => comm_attr.first.id, :module_project_id => module_project.previous.first.id).first
        new_level_estimation_values = estimation_value.send("string_data_#{level}")
        text_field_tag "[#{level}][#{est_val_pe_attribute.alias.to_sym}][#{module_project.id}]",
                       new_level_estimation_values[pbs_project_element.id],
                       :class => "input-small #{level} #{est_val.id}",
                       "data-est_val_id" => est_val.id
      end
    end
  end


  #Display rule and options of an attribute in a bootstrap tooltip
  def display_rule(est_val)
    "<br> #{I18n.t(:tooltip_attribute_rules)}: <strong>#{est_val.pe_attribute.options.join(' ')} </strong> <br> #{est_val.is_mandatory ? I18n.t(:mandatory) : I18n.t(:no_mandatory) }"
  end

  #Display Security_Level Description in a bootstrap tooltip
  def display_security_level_description(security_level)
    "#{security_level.description}"
  end

  def display_path(res, mp, i)
    if mp.previous[i].nil?
      res << ([mp] + mp.previous).flatten.reverse.join('<br>')
    else
      display_path(res, mp.previous[i], i)
    end
    res
  end

  def send_notice(project)
    if project.state == "in_progress"
      I18n.t(:warning_project_state_to_checkpoint, :value_b => 'RELEASED')
    elsif project.state == "in_review"
      I18n.t(:warning_project_state_to_released, :value_b => 'RELEASED')
    end

  end

  #Helper method that build project history graph
  def build_project_history_graph
    #Project.arrange_as_array.each{|n| "#{'-' * n.depth} #{n.version}" }
    Project.arrange_as_json.each do |n|
      project = Project.find(n[:id])
      "#{'-' * project.depth} #{n[:title]}"
    end
  end

  def build_project_history_graph_as_array
    #Project.arrange_as_array.each{|n| "#{'-' * n.depth} #{n.version}" }
    Project.arrange_as_array.each do |n|
      "#{'-' * n.depth} #{n.title}"
    end
  end

  def build_project_history_graph_json
    proj = Project.find(304)
  end

  def helper_show_project_history
    @projects.each do |prj|
      "#{'-' * prj[0].depth} #{prj[0].title}(#{prj[0].version})"
    end
  end


  def show_project_history_graph(project)
    require 'gratr/import'
    require 'gratr/dot'

    #ObjectSpace.each_object(Module) do |m|
    #  m.ancestors.each {|a| module_graph.add_edge!(m,a) if m != a}
    #end
    project = Project.find(301)
    project_root = project.root
    project_tree = project_root.subtree

    module_graph = Digraph.new

    project_tree.each do |proj|
      #proj.parent.each {|parent| module_graph.add_edge!(parent.version, proj.version) if proj != parent} unless proj.is_root?
      module_graph.add_edge!(proj.parent.version, proj.version) unless proj.is_root?
      proj.children.each {|child| module_graph.add_edge!(proj.version, child.version) if proj != child}
    end

    gv = module_graph.vertices.select {|v| v.to_s.match(/GRATR/)}
    #module_graph.induced_subgraph(gv).write_to_graphic_file('jpg','module_graph_project')
    module_graph.write_to_graphic_file('jpg','graph_project_history')

  end
end
