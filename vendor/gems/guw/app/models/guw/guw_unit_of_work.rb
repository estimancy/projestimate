module Guw
  class GuwUnitOfWork < ActiveRecord::Base

    belongs_to :guw_type
    belongs_to :guw_model
    belongs_to :guw_complexity
    belongs_to :guw_unit_of_work_group
    belongs_to :organization_technology

    has_many :guw_unit_of_work_attributes, dependent: :destroy

    ###validates_presence_of :name, :guw_type_id, :guw_unit_of_work_group_id, :display_order

    amoeba do
      enable
      include_association [:guw_unit_of_work_attributes]
    end

    def to_s
      name
    end
  end
end
