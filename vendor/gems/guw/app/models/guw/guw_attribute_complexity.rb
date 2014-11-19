module Guw
  class GuwAttributeComplexity < ActiveRecord::Base
    belongs_to :guw_type

    def to_s
      name
    end
  end
end
