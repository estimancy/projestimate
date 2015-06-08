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

FactoryGirl.define do

  sequence :organization_name do |n|
    "Organization_#{n}"
  end

  # Organizations
  factory :organization do
    #sequence(:name) {|n| "Organization_#{n}"}
    name { generate(:organization_name) }
    sequence(:description) {|n| "Organization number #{n}"}
    number_hours_per_day 7
    number_hours_per_month 140
    cost_per_hour 10
    limit1 10
    limit2 100
    limit3 1000
    association :currency, :factory => :euro_curreny
  end

end