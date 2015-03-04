# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class UowInput < ActiveRecord::Base
  belongs_to :module_project
  belongs_to :organization_technology, :foreign_key => :technology_id
  belongs_to :unit_of_work
  belongs_to :organization_uow_complexity, :foreign_key => :complexity_id
  belongs_to :size_unit_type

  #validates :technology_id, :unit_of_work_id, presence: true

  def self.export(mp, pbs)
    @inputs = UowInput.where(module_project_id: mp, pbs_project_element_id: pbs).all
    csv_string = CSV.generate(:col_sep => I18n.t(:general_csv_separator)) do |csv|
      csv << ['id', 'Organization', 'Reference', 'Technology', 'Unit Of Work', 'Complexity', 'Type', 'Low', 'Most Likely', 'High', 'Weight']
      @inputs.each do |i|
        begin
          csv << ["#{i.id}", "#{i.organization_technology.organization.name}", "#{i.name}", "#{i.organization_technology}", "#{i.unit_of_work}", "#{i.organization_uow_complexity}", "#{i.size_unit_type.name}",
                  "#{i.size_low}", "#{i.size_most_likely}", "#{i.size_high}",
                  "#{i.weight}"]
        rescue

        end
      end
    end
    csv_string.encode(I18n.t(:general_csv_encoding))
  end

  def self.import(file, sep, encoding, component, module_project)
    sep = "#{sep.blank? ? I18n.t(:general_csv_separator) : sep}"
    error_count = 0
    CSV.open(file.path, 'r', :quote_char => "\"", :row_sep => :auto, :col_sep => sep, :encoding => "#{encoding}:utf-8") do |csv|
      csv.each_with_index do |row, i|
        unless row.empty? or i == 0
          #begin
            @ware = UowInput.find_by_id(row[0])
            unless @ware.nil?
              #@ware.update_attribute('organization_id', row[1])
              @ware.update_attribute('name', row[2])
              #@ware.update_attribute('technology_id', row[3])
              #@ware.update_attribute('unit_of_work_id', row[4])
              #@ware.update_attribute('complexity_id', row[5])
              #@ware.update_attribute('size_unit_type_id', row[6])
              @ware.update_attribute('size_low', row[7])
              @ware.update_attribute('size_most_likely', row[8])
              @ware.update_attribute('size_high', row[9])
              @ware.update_attribute('weight', row[10])
            else

              o = Organization.find_by_name(row[1].to_i)
              t = OrganizationTechnology.where(name: row[3], organization_id: o.id).first
              u = UnitOfWork.where(name: row[4], organization_id: o.id).first
              c = OrganizationUowComplexity.where(name: row[5], organization_id: o.id).first
              sut = SizeUnitType.where(name: row[6], organization_id: o.id).first

              begin
                i = UowInput.new(name: row[2],
                              technology_id: t.id,
                              unit_of_work_id: u.id,
                              complexity_id: c.id,
                              size_unit_type_id: sut.id,
                              pbs_project_element_id: component.id,
                              module_project_id: module_project.id,
                              flag: "black-question-mark",
                              size_low: row[7], size_most_likely: row[8], size_high: row[9], weight: row[10])

                i.save
              rescue
              end
            end
          #rescue
          #  error_count = error_count + 1
          #end
        end
      end
    end
    error_count
  end
end