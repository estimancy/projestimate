module ExpertJudgement
  class Instance < ActiveRecord::Base
    belongs_to :organization
    validates_presence_of :name, :organization_id
  end
end
