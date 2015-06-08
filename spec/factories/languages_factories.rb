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

# Language

FactoryGirl.define do

  factory :language do
    sequence(:name)   {|n| "language_#{n}"}
    sequence(:locale) {|n| "locale_#{n}"}
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :en_language, :class => Language do
    name "English"
    locale "en"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :fr_language, :class => Language do
    name "Francais"
    locale "fr"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :it_language, :class => Language do
    name "Italien"
    locale "it"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :de_language, :class => Language do
    name "Deutsch"
    locale "de"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :en_gb_language, :class => Language do
    name "English (British)"
    locale "en-gb"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end


  #factory :en_language, :class => Language do
  #  sequence(:name)   {|n| "english#{n}"}
  #  sequence(:locale) {|n| "locale_english#{n}"}
  #  uuid
  #  association :record_status, :factory => :proposed_status, strategy: :build
  #end
  #
  #factory :fr_language, :class => Language do
  #  sequence(:name)   {|n| "fr#{n}"}
  #  sequence(:locale) {|n| "locale_fr#{n}"}
  #  uuid
  #  association :record_status, :factory => :proposed_status, strategy: :build
  #end

end
