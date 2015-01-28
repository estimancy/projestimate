module ExpertJudgement
  class InstanceEstimate < ActiveRecord::Base
    belongs_to :pbs_project_element
    belongs_to :module_project
    belongs_to :pe_attribute
    belongs_to :instance, foreign_key: "expert_judgement_instance_id"

    def convert_effort(eja, ev)
      gross = (self.most_likely_input.blank? ? ev.nil? ? '' : ev.string_data_most_likely[current_component.id] : self.most_likely_input).to_f
      if eja.alias == "effort"
        gross * self.instance.effort_unit_coefficient
      elsif eja.alias == "cost"
        gross * self.instance.cost_unit_coefficient
      else
        gross
      end
    end
  end
end
