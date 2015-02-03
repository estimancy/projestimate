module ExpertJudgement
  class InstanceEstimate < ActiveRecord::Base
    belongs_to :pbs_project_element
    belongs_to :module_project
    belongs_to :pe_attribute
    belongs_to :instance, foreign_key: "expert_judgement_instance_id"

    def convert_effort(level, eja, ev)
      gross = (self.send("#{level}_input").blank? ? ev.nil? ? '' : ev.send("#{level}_input")[current_component.id] : self.send("#{level}_input")).to_f
      if eja.alias == "effort"
        gross * self.instance.effort_unit_coefficient.to_f
      elsif eja.alias == "cost"
        gross * self.instance.cost_unit_coefficient.to_f
      else
        gross
      end
    end

    def to_s(mp)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      end
    end
  end
end
