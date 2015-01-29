module Guw
  class GuwModel < ActiveRecord::Base

    has_many :guw_types
    has_many :guw_unit_of_works
    has_many :guw_attributes
    has_many :guw_work_units

    belongs_to :organization
    belongs_to :module_project

    validates_presence_of :name, :organization_id

    #Search fields
    scoped_search :on => [:name]

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      end
    end

  end
end
