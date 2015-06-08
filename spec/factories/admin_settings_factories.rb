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

## Admin Settings
FactoryGirl.define do
   sequence :key do |n|
     "key_#{n}"
   end

   sequence :value do |n|
     "value_#{n}@email.com"
   end

   factory :admin_setting do
     uuid
     #association :record_status, :factory => :proposed_status, :strategy => :build

     trait :welcome_message do
       uuid
       key     #key "welcome_message"
       value   #value "This is my welcome message"
       association :record_status, :factory => :proposed_status, :strategy => :build
     end

     trait :notifications_email do
       uuid
       key    #key   "notifications_email"
       value  #value "AdminSpirula@email.com"
       association :record_status, :factory => :proposed_status, :strategy => :build
     end

     trait :password_min_length do
       uuid
       key    #key "password_min_length"
       value  #value "4"
       association :record_status, :factory => :proposed_status, :strategy => :build
     end

     factory :welcome_message_ad do
       welcome_message
     end

     factory :notifications_email_ad do
       notifications_email
     end

   end
end
