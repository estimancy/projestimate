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

  #factory :folder, :class => Component do |cl|
  #  cl.name "Folder1"
  #  cl.is_root false
  #  cl.association :work_element_type#, :factory =>  :work_element_type_folder
  #end

  factory :pbs_project_element do
    name "Component"
    is_root false
    start_date Time.now

    trait :pbs_trait_folder do
      name "Folder"
    end

    trait :pbs_trait_bad do
      name "bad"
    end
  end

  factory :pbs_folder, :class => PbsProjectElement do
    name "Folder"
    is_root false
    start_date Time.now
  end

  factory :pbs_bad, :class => PbsProjectElement do |cl|
    cl.name ""
    cl.is_root false
    start_date Time.now
  end

end
