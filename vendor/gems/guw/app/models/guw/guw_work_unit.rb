module Guw
  class GuwWorkUnit < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_complexity_work_units

    validates_presence_of :name, :value

    def to_s
      name
    end
  end
end
