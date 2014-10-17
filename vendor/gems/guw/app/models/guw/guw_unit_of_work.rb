module Guw
  class GuwUnitOfWork < ActiveRecord::Base

    belongs_to :guw_type
    belongs_to :guw_model
    belongs_to :guw_complexity
    has_many :guw_unit_of_work_attributes

    def to_s
      name
    end
  end
end
