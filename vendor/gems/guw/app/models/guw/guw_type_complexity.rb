module Guw
  class GuwTypeComplexity < ActiveRecord::Base
    belongs_to :guw_type
    has_many :guw_attribute_complexities, dependent: :delete_all

    validates_presence_of :name, :value###, :guw_type_id

    amoeba do
      enable
      exclude_association [:guw_attribute_complexities]
      customize(lambda { |original_guw_type_complexity, new_guw_type_complexity|
        new_guw_type_complexity.copy_id = original_guw_type_complexity.id
      })
    end

    def to_s
      name
    end

  end
end
