module Guw
  class GuwTypeComplexity < ActiveRecord::Base
    belongs_to :guw_type
    has_many :attribute_complexities, dependent: :destroy

    validates_presence_of :name, :value, :guw_type_id

  end
end
