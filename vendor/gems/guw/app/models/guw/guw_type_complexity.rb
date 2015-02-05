module Guw
  class GuwTypeComplexity < ActiveRecord::Base
    belongs_to :guw_type
    has_many :guw_attribute_complexities, dependent: :delete_all
    validates_presence_of :name, :value, :guw_type_id
  end
end
