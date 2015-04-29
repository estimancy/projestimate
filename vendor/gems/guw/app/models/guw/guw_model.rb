module Guw
  class GuwModel < ActiveRecord::Base

    has_many :guw_types, dependent: :destroy
    has_many :guw_unit_of_works, dependent: :destroy
    has_many :guw_attributes, dependent: :destroy
    has_many :guw_work_units, dependent: :destroy
    has_many :module_projects, dependent: :destroy

    belongs_to :organization

    validates_presence_of :name####, :organization_id

    #Search fields
    scoped_search :on => [:name]

    amoeba do
      enable
      include_association [:guw_types, :guw_attributes, :guw_work_units]

      customize(lambda { |original_guw_model, new_guw_model|
        new_guw_model.copy_id = original_guw_model.id
      })
    end

    def to_s(mp=nil)
      if mp.nil?
        self.name
      else
        "#{self.name} (#{Projestimate::Application::ALPHABETICAL[mp.position_x.to_i-1]};#{mp.position_y.to_i})"
      end
    end

    #Duplicate the GuwModel
    def duplicate_model
      guw_model = self
      organization = self.organization
      guw_model = guw_model.amoeba_dup

      guw_model.transaction do
        if guw_model.save

          guw_model.guw_types.each do |guw_type|

            # Copy the complexities technologies
            guw_type.guw_complexities.each do |guw_complexity|
              # Copy the complexities technologie
              guw_complexity.guw_complexity_technologies.each do |guw_complexity_technology|
                new_organization_technology = organization.organization_technologies.where(copy_id: guw_complexity_technology.organization_technology_id).first
                unless new_organization_technology.nil?
                  guw_complexity_technology.update_attribute(:organization_technology_id, new_organization_technology.id)
                end
              end

              # Copy the complexities units of works
              guw_complexity.guw_complexity_work_units.each do |guw_complexity_work_unit|
                new_guw_work_unit = guw_model.guw_work_units.where(copy_id: guw_complexity_work_unit.guw_work_unit_id).first
                unless new_guw_work_unit.nil?
                  guw_complexity_work_unit.update_attribute(:guw_work_unit_id, new_guw_work_unit.id)
                end
              end
            end

            # Copy the GUW-attribute-complexity
            guw_type.guw_type_complexities.each do |guw_type_complexity|
              guw_type_complexity.guw_attribute_complexities.each do |guw_attr_complexity|
                new_guw_attribute = guw_model.guw_attributes.where(copy_id: guw_attr_complexity.guw_attribute_id).first
                unless new_guw_attribute.nil?
                  guw_attr_complexity.update_attributes(guw_type_id: new_guw_attribute.guw_type_id, guw_attribute_id: new_guw_attribute.id)
                end
              end
            end
          end
        end
      end
    end

  end
end
