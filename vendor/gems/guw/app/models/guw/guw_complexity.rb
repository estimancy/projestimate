module Guw
  class GuwComplexity < ActiveRecord::Base
    belongs_to :guw_type
    validates_presence_of :name#, :guw_type_id#, :bottom_range, :top_range,

    validates :bottom_range, numericality: { only_integer: true }
    validates :top_range, numericality: { only_integer: true }

    amoeba do
      enable
    end

  end
end
