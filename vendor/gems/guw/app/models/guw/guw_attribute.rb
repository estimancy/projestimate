module Guw
  class GuwAttribute < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_attribute_complexities

    validates_presence_of :name

    def to_s
      name
    end
  end
end