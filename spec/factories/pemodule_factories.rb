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

  #Pemodule
  factory :pemodule do |mo|
    mo.sequence(:title) {|n| "Module_#{n}" }
    mo.sequence(:alias) {|n| "module#{n}" }
    mo.description "Module description"
    mo.uuid "#{UUIDTools::UUID.random_create.to_s}"
    mo.association :record_status, :factory => :defined_status, strategy: :build
    mo.with_activities 'no'
  end

end



#    # ModuleProject
#    #factory :module_project_save, :class => ModuleProject do |mp|
#    #  mp.association :pemodule, factory => :pemodule
#    #  mp.association :project, factory => :project
#    #  mp.position_x { |x| x.position_x = FactoryGirl.next(:position_x) }
#    #  mp.position_y { |y| y.position_y = FactoryGirl.next(:position_y)}
#    #end
#    #
#    #factory :module_project_save, :class => ModuleProject do |mp|
#    #  mp.association :pemodule, factory => :pemodule
#    #  mp.association :project, factory => :project
#    #  mp.position_x { |x| x.position_x = FactoryGirl.next(:position_x) }
#    #  mp.position_y { |y| y.position_y = FactoryGirl.next(:position_y)}
#    #end
#
#    factory :module_project1, :class => ModuleProject do |mp|
#      #mp.association :pemodule, factory => :pemodule
#      #mp.association :project, factory => :pe_project
#      mp.position_x 1
#      mp.position_y 1
#    end
#
#    #factory :module_project2, :class => ModuleProject do |mp|
#    #  #mp.association :pemodule, factory => :pemodule
#    #  #mp.association :project, factory => :pe_project
#    #  mp.position_x 1
#    #  mp.position_y 2
#    #end
#
#    #factory sequence(:module_project) { |mp| "module_project#{n}"}, :class => ModuleProject do
#    #  mp.association :pemodule, factory => :pemodule
#    #  mp.association :project, factory => :project
#    #  mp.position_x { |x| x.position_x = FactoryGirl.next(:position_x) }
#    #  mp.position_y { |y| y.position_y = FactoryGirl.next(:position_y)}
#    #end
#

