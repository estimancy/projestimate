module Guw
  class GuwUnitOfWork < ActiveRecord::Base

    belongs_to :guw_type

    def to_s
      name
    end
  end
end
