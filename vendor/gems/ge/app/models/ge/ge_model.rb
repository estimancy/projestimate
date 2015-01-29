module Ge
  class GeModel < ActiveRecord::Base
    validates_presence_of :name, :organization_id

    belongs_to :organization
    belongs_to :module_project

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      end
    end
  end
end
