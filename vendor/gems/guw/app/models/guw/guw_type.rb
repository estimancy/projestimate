module Guw
  class GuwType < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_attribute_complexities
    has_many :guw_complexities

    def to_s
      name
    end
  end
end
