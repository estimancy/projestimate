module Guw
  class GuwType < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_attribute_complexities
    has_many :guw_complexities
    has_many :guw_type_complexities
    has_many :guw_unit_of_works

    def to_s
      name
    end
  end
end
