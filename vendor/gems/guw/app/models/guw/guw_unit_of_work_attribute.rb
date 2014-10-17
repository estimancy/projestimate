module Guw
  class GuwUnitOfWorkAttribute < ActiveRecord::Base

    belongs_to :guw_type
    belongs_to :guw_unit_of_work
    belongs_to :guw_attribute
    belongs_to :guw_attribute_complexity

    def to_s
      name
    end
  end
end
