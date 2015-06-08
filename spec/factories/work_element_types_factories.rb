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

## Work Element Types
#
FactoryGirl.define do

  factory :work_element_type , :class => WorkElementType do
    sequence(:name) {|n| "Wet_#{n}"}
    sequence(:alias) {|n| "wet_alias#{n}"}

    association :record_status, :factory => :proposed_status, strategy: :build

    trait :wet_folder do
      sequence(:name) {|n| "Folder_#{n}"}
      sequence(:alias) {|n| "folder_alias#{n}"}
      uuid
    end

    trait :wet_link do
      sequence(:name) {|n| "Link_#{n}"}
      sequence(:alias) {|n| "link_alias#{n}"}
      uuid
    end


    trait :wet_undefined do
      sequence(:name) {|n| "Undefined_#{n}"}
      sequence(:alias) {|n| "undefined_alias#{n}"}
      uuid
    end


    trait :wet_default do
      sequence(:name) {|n| "Default_#{n}"}
      sequence(:alias) {|n| "default_alias#{n}"}
      uuid
    end


    trait :wet_developed_software do
      sequence(:name) {|n| "Developed_software_#{n}"}
      sequence(:alias) {|n| "Developed_software__alias#{n}"}
      uuid
    end
  end
end

