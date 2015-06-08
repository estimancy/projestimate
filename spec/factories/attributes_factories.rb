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

#PeAttributes
FactoryGirl.define do
  factory :cost_attribute, :class => :pe_attribute  do |attr|
     attr.name "Cost"
     attr.alias "cost"
     attr.description "Cost desc"
     attr.attr_type "integer"
     attr.options []
     uuid
     association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :sloc_attribute, :class => :pe_attribute do |attr|
     attr.name "Sloc1"
     attr.alias "sloc1"
     attr.description "Attribute number 1"
     attr.attr_type "integer"
     attr.options ["integer", ">=", "10"]
     uuid
     association :record_status, :factory => :proposed_status, strategy: :build
  end
end