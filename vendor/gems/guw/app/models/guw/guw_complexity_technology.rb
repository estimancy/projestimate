module Guw
  class GuwComplexityTechnology < ActiveRecord::Base
    belongs_to :guw_technology
    belongs_to :guw_complexity
  end
end
