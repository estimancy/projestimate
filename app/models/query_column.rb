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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class QueryColumn

  attr_accessor :name, :caption, :association_name, :field_id, :organization_id

  def initialize(name, options={})
    self.name = name
    #self.association_name = association_name
    self.caption = options[:caption]
    self.field_id = options[:field_id]
    self.organization_id = options[:organization_id]
  end

  def value(object)
    object.send name
  end

  def value_object(object)
    begin
      object.send(name)
    rescue
      ''
    end
  end

  def project_field_value(object)
    field = Field.find(self.field_id)
    value = '-'
    unless field.coefficient.nil?
      project_field = ProjectField.where(field_id: self.field_id, project_id: object.id).last
      #value = project_field.nil? ? '-' : convert_with_precision(project_field.value.to_f / field.coefficient.to_f, user_number_precision)
      value = project_field.nil? ? '-' : convert_with_precision(project_field.value.to_f / field.coefficient.to_f, 2)
    end
    value
  end

  def css_classes
    name
  end

  def convert_with_precision(value, precision)
    "%.#{precision}f" % value
  end

end