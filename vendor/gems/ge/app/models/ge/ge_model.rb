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

    def self.display_size(p, c, level, component_id)
      if c.send("string_data_#{level}")[component_id].nil?
        begin
          p.send("string_data_#{level}")[component_id]
        rescue
          nil
        end
      else
        c.send("string_data_#{level}")[component_id]
      end
    end
  end
end
