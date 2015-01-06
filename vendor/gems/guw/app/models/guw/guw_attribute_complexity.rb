module Guw
  class GuwAttributeComplexity < ActiveRecord::Base
    belongs_to :guw_type
    belongs_to :guw_type_complexity

    def to_s
      name
    end
  end
end
