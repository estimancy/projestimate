module Guw
  class GuwModel < ActiveRecord::Base

    has_many :guw_types, dependent: :destroy
    has_many :guw_unit_of_works, dependent: :destroy
    has_many :guw_attributes, dependent: :destroy
    has_many :guw_work_units, dependent: :destroy
    has_many :module_projects, dependent: :destroy

    belongs_to :organization

    validates_presence_of :name####, :organization_id

    #Search fields
    scoped_search :on => [:name]

    amoeba do
      enable
      include_association [:guw_types, :guw_attributes, :guw_work_units]

      customize(lambda { |original_guw_model, new_guw_model|
        new_guw_model.copy_id = original_guw_model.id
      })
    end

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      end
    end

  end
end
