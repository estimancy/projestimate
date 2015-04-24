module Guw
  class GuwAttribute < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_attribute_complexities

    validates_presence_of :name

    amoeba do
      enable
      customize(lambda { |original_guw_attribute, new_guw_attribute|
        new_guw_attribute.copy_id = original_guw_attribute.id
      })
    end

    def to_s
      name
    end
  end
end
