module Guw
  class GuwUnitOfWork < ActiveRecord::Base

    belongs_to :guw_type
    belongs_to :guw_model
    belongs_to :guw_complexity
    belongs_to :guw_unit_of_work_group
    has_many :guw_unit_of_work_attributes, dependent: :destroy

    validates_presence_of :name, :guw_type_id, :guw_unit_of_work_group_id, :display_order

    def to_s
      name
    end
  end
end
