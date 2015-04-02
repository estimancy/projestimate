module Amoa
  class AmoaModel < ActiveRecord::Base
    validates_presence_of :name, :organization_id

    belongs_to :organization
    has_many :module_projects, :dependent => :destroy

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      end
    end
  end
end
