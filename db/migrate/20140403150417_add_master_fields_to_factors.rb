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

class AddMasterFieldsToFactors < ActiveRecord::Migration
  def change
    add_column :factors, :uuid, :string
    add_column :factors, :record_status_id, :integer
    add_column :factors, :custom_value, :string
    add_column :factors, :owner_id, :integer
    add_column :factors, :change_comment, :text
    add_column :factors, :reference_id, :integer
    add_column :factors, :reference_uuid, :string
  end
end
