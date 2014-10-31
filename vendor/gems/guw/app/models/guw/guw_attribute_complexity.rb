module Guw
  class GuwAttributeComplexity < ActiveRecord::Base
    belongs_to :guw_type

    validates_presence_of :name, :bottom_range, :top_range, :value, :guw_type_id

    validates :bottom_range, numericality: { only_integer: true }
    validates :top_range, numericality: { only_integer: true }
  end
end
