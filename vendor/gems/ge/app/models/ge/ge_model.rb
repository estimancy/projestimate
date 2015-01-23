module Ge
  class GeModel < ActiveRecord::Base
    validates_presence_of :name, :organization_id

    belongs_to :organization
    belongs_to :module_project

    def to_s
      name
    end
  end
end
