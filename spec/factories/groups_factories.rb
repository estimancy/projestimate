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

  sequence :group_name do |n|
    "group#{n}"
  end


  factory :group do
    name { generate(:group_name) } #sequence(:name) {|n| "group#{n}"}
    sequence(:description) {|n| "Group number #{n}"}
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
    for_global_permission true
  end

  factory :defined_group, :class => :group do
    name { generate(:group_name) }  #sequence(:name) {|n| "group#{n}"}
    sequence(:description) {|n| "Group number #{n}"}
    uuid
    association :record_status, :factory => :defined_status, strategy: :build
    for_global_permission true
  end

  factory :admin_group, :class => :group do
    name "Admin"
    description "ProjEstimate administrators"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
    for_global_permission true
  end

  factory :everyone_group, :class => :group do
    name "Everyone"
    description "All user accounts identified in ProjEstimate. At creation, each account is automatically added to this group. But this group stay a regular group with same behavior than all the other groups, so the administrator can remove any accounts he want from this group."
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
    for_global_permission true
  end

  factory :master_admin_group, :class => :group do
    name "MasterAdmin"
    description "Administrators of the ProjEstimate configuration"
    uuid
    association :record_status, :factory => :defined_status, strategy: :build
    for_global_permission true
  end


end