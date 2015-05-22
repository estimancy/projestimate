module Guw
  class GuwAttribute < ActiveRecord::Base
    belongs_to :guw_model
    has_many :guw_attribute_complexities
    has_many :guw_unit_of_work_attributes
    validates_presence_of :name

    amoeba do
      enable

      exclude_association [:guw_unit_of_work_attributes]

      customize(lambda { |original_guw_attribute, new_guw_attribute|
        new_guw_attribute.copy_id = original_guw_attribute.id
      })
    end

    def to_s
      name
    end
  end
end
