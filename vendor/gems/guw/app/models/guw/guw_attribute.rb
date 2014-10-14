module Guw
  class GuwAttribute < ActiveRecord::Base
    has_many :guw_complexities

    def to_s
      name
    end
  end
end
