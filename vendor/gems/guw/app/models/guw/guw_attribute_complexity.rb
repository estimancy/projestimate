module Guw
  class GuwAttributeComplexity < ActiveRecord::Base
    belongs_to :guw_type
    belongs_to :guw_type_complexity

    amoeba do
      enable
    end

  end
end
