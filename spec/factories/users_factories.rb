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

# User

FactoryGirl.define do

  factory :admin, :class => :user do
    first_name "Administrator"
    last_name  "Projestimate"
    login_name "admin"
    email      "youremail@yourcompany.net"
    time_zone  "GMT"
    initials   "ad"
    association :auth_method, :factory => :auth_method, strategy: :build
    association :language, :factory => :language, :strategy => :build
    password   "projestimate"
    password_confirmation "projestimate"
    confirmed_at Time.now
  end

  factory :authenticated_user, :class => :user do
    first_name
    last_name
    login_name
    email
    initials
    association :auth_method, :factory => :auth_method
    association :language, :factory => :language, :strategy => :build
    password   "projestimate"
    password_confirmation "projestimate"
  end


  factory :user3, :class => :user do
    first_name #"Administrator3"
    last_name  #"Projestimate3"
    login_name #"admin3"
    email      #"admin3@yourcompany.net"
    initials   #"ad3"
    association :auth_method, :factory => :auth_method, strategy: :build
    association :language, :factory => :language, :strategy => :build
    password   "projestimate3"
    password_confirmation "projestimate3"
    confirmed_at Time.now
  end
end
