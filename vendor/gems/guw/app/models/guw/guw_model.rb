module Guw
  class GuwModel < ActiveRecord::Base

    has_many :guw_types
    belongs_to :organization

    def to_s
      name
    end
  end
end
