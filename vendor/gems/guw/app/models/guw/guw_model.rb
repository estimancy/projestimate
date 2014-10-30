module Guw
  class GuwModel < ActiveRecord::Base

    has_many :guw_types
    has_many :guw_unit_of_works
    has_many :guw_attributes
    belongs_to :organization

    validates_presence_of :name, :organization_id

    def to_s
      name
    end
  end
end
