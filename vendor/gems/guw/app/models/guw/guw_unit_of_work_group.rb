module Guw
  class GuwUnitOfWorkGroup < ActiveRecord::Base

    has_many :guw_unit_of_works

    validates_presence_of :name

    def to_s
      name
    end
  end
end
