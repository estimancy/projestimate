module ExpertJudgement
  class InstanceEstimate < ActiveRecord::Base
    belongs_to :pbs_project_element
    belongs_to :module_project
    belongs_to :pe_attribute
    belongs_to :instance
  end
end
