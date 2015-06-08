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

  #PeWbsProject
  factory :pe_wbs_project do
    sequence(:name){|n| "Pe-Wbs-Project_Root #{n}"}

    trait :wbs_product do
      wbs_type "Product"
    end

    trait :wbs_activity do
      wbs_type "Activity"
    end

  end

  factory :wbs_1, class: PeWbsProject do
    sequence(:name)   {|n| "Pe-WBS-Project_#{n}"}
    wbs_type "Product"
  end

end
