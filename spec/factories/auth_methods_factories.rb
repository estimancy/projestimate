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

## Auth Method

FactoryGirl.define do

  factory :auth_method do
    sequence(:name) {|n| "Application_#{n}"}        #name "Application"
    server_name "not Necessary"
    user_name_attribute "ldap_user"
    port 0
    base_dn "Not necessary"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
    encryption "simple_tls"
  end

  factory :auth_methodLDAP do
    sequence(:name) {|n| "Application_LDAP_#{n}"}        #name "Application"
    server_name "gpsforprojects.net"
    user_name_attribute "ldap_user"
    port 636
    base_dn "ou=People,dc=gpsforprojects,dc=net"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
    encryption "simple_tls"
  end

  #Factory for the "Application" AuthMethod

  factory :application_auth_method, :class => :auth_method do
    name "Application"
    server_name "not Necessary"
    user_name_attribute "ldap_user"
    port 0
    base_dn "Not necessary"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
    encryption "simple_tls"
  end
end