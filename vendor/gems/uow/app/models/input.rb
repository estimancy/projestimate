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

class Input < ActiveRecord::Base
  belongs_to :module_project
  belongs_to :organization_technology, :foreign_key => :technology_id

  validates :technology_id, :unit_of_work_id, presence: true

  def self.export(mp, pbs)
    @inputs = Input.where(module_project_id: mp, pbs_project_element_id: pbs).all
    csv_string = CSV.generate(:col_sep => I18n.t(:general_csv_separator)) do |csv|
      csv << ['id', 'Reference', 'Technology', 'Unit Of Work', 'Complexity', 'Type', 'Low', 'Most Likely', 'High', 'Weight']
      @inputs.each do |i|
        csv << ["#{i.id}", "#{i.name}", "#{i.technology_id}", "#{i.unit_of_work_id}", "#{i.complexity_id}", "#{i.size_unit_type_id}",
                "#{i.size_low}", "#{i.size_most_likely}", "#{i.size_high}",
                "#{i.weight}"]
      end
    end
    csv_string.encode(I18n.t(:general_csv_encoding))
  end

  def self.import(file, sep, encoding)
    sep = "#{sep.blank? ? I18n.t(:general_csv_separator) : sep}"
    error_count = 0
    CSV.open(file.path, 'r', :quote_char => "\"", :row_sep => :auto, :col_sep => sep, :encoding => "#{encoding}:utf-8") do |csv|
      csv.each_with_index do |row, i|
        unless row.empty? or i == 0
          begin
            @ware = Input.find(row[0])
            @ware.update_attribute('name', row[1])
            @ware.update_attribute('technology_id', row[2])
            @ware.update_attribute('unit_of_work_id', row[3])
            @ware.update_attribute('complexity_id', row[4])
            @ware.update_attribute('size_unit_type_id', row[4])
            @ware.update_attribute('size_low', row[5])
            @ware.update_attribute('size_most_likely', row[6])
            @ware.update_attribute('size_high', row[7])
            @ware.update_attribute('weight', row[8])
          rescue
            error_count = error_count + 1
          end
        end
      end
    end
    error_count
  end


end