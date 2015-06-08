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

# Currencies

FactoryGirl.define do

  factory :euro_curreny, :class => Currency do |cu|
    sequence(:name) {|n| "EUR#{n}"}
    sequence(:alias) {|n| "eur#{n}"}
    sequence(:description) {|n| "description#{n}"}
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  #factory :dollar_curreny, :class => Currency do |cu|
  #  cu.name   "US Dollar"
  #  cu.alias  "USD"
  #  cu.description  "TBD"
  #  uuid
  #  association :record_status, :factory => :proposed_status, strategy: :build
  #end
  #
  #factory :pound_curreny, :class => Currency do |cu|
  #  cu.name   "British Pound"
  #  cu.alias  "GBP"
  #  cu.description  "TBD"
  #  uuid
  #  association :record_status, :factory => :proposed_status, strategy: :build
  #end

end
