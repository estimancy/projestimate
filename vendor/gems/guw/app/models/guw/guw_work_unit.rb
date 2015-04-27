module Guw
  class GuwWorkUnit < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_complexity_work_units

    validates_presence_of :name, :value

    amoeba do
      enable
      exclude_association [:guw_complexity_work_units]

      customize(lambda { |original_guw_work_unit, new_guw_work_unit|
        new_guw_work_unit.copy_id = original_guw_work_unit.id
      })
    end

    def to_s
      name
    end
  end
end
