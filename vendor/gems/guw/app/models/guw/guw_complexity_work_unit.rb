module Guw
  class GuwComplexityWorkUnit < ActiveRecord::Base
    belongs_to :guw_work_unit
    belongs_to :guw_complexity

    #amoeba do
    #  enable
    #end
  end
end
