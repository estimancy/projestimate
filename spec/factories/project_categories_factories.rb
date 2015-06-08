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

  factory :unknown_project_category, :class => ProjectCategory do
    name "Unknown"
    description  "TBD"
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :multimedia_project_category, :class => ProjectCategory do
    name "Mulimedia"
    description  "TBD"
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :network_management_project_category, :class => ProjectCategory do
    name  "Network Management"
    description  "TBD"
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :office_automation_project_category, :class => ProjectCategory do
    name  "Office Automation"
    description  "TBD"
    association :record_status, :factory => :proposed_status, strategy: :build
  end

end

