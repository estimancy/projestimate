module Guw
  class GuwType < ActiveRecord::Base
    belongs_to :guw_model

    has_many :guw_unit_of_work_attributes, dependent: :destroy
    has_many :guw_attribute_complexities, dependent: :destroy
    has_many :guw_complexities, dependent: :destroy
    has_many :guw_type_complexities, dependent: :destroy
    has_many :guw_unit_of_works, dependent: :destroy

    validates_presence_of :name

    def to_s
      name
    end
  end
end