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

CocomoAdvanced::Engine.routes.draw do
  get "input_cocomo/index"
  get "input_cocomo/help/:factor_id" => "input_cocomo#help", :as => "help"

  get 'add_note_to_factor/:factor_id' => 'input_cocomo#add_note_to_factor', :as => 'add_note_to_factor'
  post 'notes_form/:factor_id' => 'input_cocomo#notes_form', :as => 'notes_form'

  post "cocomo_save" => "input_cocomo#cocomo_save", :as => "cocomo_save"
  root :to => 'input_cocomo#index'
end
