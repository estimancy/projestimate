module Guw
  class GuwUnitOfWorkGroup < ActiveRecord::Base

    has_many :guw_unit_of_works, dependent: :destroy

    belongs_to :module_project
    belongs_to :pbs_project_element
    belongs_to :organization_technology

    validates_presence_of :name#, :organization_technology_id

    amoeba do
      enable
      include_association [:guw_unit_of_works]
    end

    def to_s
      name
    end
  end
end
