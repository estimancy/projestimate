module Guw
  class GuwComplexity < ActiveRecord::Base
    belongs_to :guw_type
    validates_presence_of :name, :bottom_range, :top_range, :guw_type_id

    validates :bottom_range, numericality: { only_integer: true }
    validates :top_range, numericality: { only_integer: true }

  end
end
