module ExpertJudgement
  class Instance < ActiveRecord::Base

    belongs_to :organization
    has_many :instance_estimates, foreign_key: "expert_judgement_instance_id"

    validates_presence_of :name, :organization_id

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      end
    end
  end
end
