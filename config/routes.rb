#encoding: utf-8
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
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
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

require 'sidekiq/web'

Projestimate::Application.routes.draw do

  resources :fields


  resources :views_widgets
  get 'update_view_widget_positions' => 'views_widgets#update_view_widget_positions', :as => 'update_view_widget_positions'
  get 'update_widget_module_project_data' => 'views_widgets#update_widget_module_project_data', :as => 'update_widget_module_project_data'

  resources :widgets


  resources :views


  resources :plans


  resources :estimation_statuses
  post '/set_estimation_status_workflow' => 'estimation_statuses#set_estimation_status_workflow', as: 'set_estimation_status_workflow'
  post '/set_estimation_status_group_roles' => 'estimation_statuses#set_estimation_status_group_roles', as: 'set_estimation_status_group_roles'


  resources :profile_categories


  resources :organization_profiles
  get 'refresh_organization_profiles' => 'organization_profiles#refresh_organization_profiles', as: 'refresh_organization_profiles'
  get 'refresh_organization_profile_data' => 'organization_profiles#refresh_organization_profile_data', as: 'refresh_organization_profile_data'


  resources :profiles


  resources :size_unit_types


  resources :size_units


  # Mount the Sidekiq web interface
  mount Sidekiq::Web, at: "/sidekiq"

  resources :technologies

  resources :estimation_values
  get 'add_note_to_attribute' => 'estimation_values#add_note_to_attribute', :as => 'add_note_to_attribute'

  resources :factors

  devise_for :users, :controllers => {:registrations => "registrations", :omniauth_callbacks => "omniauth_callbacks"}

  get 'awaiting_confirmation' => 'registrations#awaiting_confirmation', :as => 'awaiting_confirmation'

  resources :users

  get 'dashboard' => 'users#show', :as => 'dashboard'
  get 'validate' => 'users#validate', :as => 'validate'
  post 'create_inactive_user' => 'users#create_inactive_user', :as => 'create_inactive_user'
  get 'find_use_user' => 'users#find_use_user', :as => 'find_use_user'
  get 'about' => 'users#about', :as => 'about'
  match 'users/:id/activate' => 'users#activate', :as => 'activate'
  get 'display_states' => 'users#display_states', :as => 'display_states'
  post 'send_feedback' => 'users#send_feedback', :as => 'send_feedback'

  resources :password_resets

  #resources :sessions
  #get 'log_in' => 'sessions#new', :as => 'log_in'
  #get 'log_out' => 'sessions#destroy', :as => 'log_out'
  #get 'ask_new_account' => 'sessions#ask_new_account', :as => 'ask_new_account'
  #get 'help_login' => 'sessions#help_login', :as => 'help_login'
  #get 'forgotten_password' => 'sessions#forgotten_password', :as => 'forgotten_password'
  #post 'reset_forgotten_password' => 'sessions#reset_forgotten_password', :as => 'reset_forgotten_password'

  resources :audits

  mount Guw::Engine, :at => '/guw'
  mount Uow::Engine, :at => '/uow'
  mount CocomoExpert::Engine, :at => '/cocomo_expert'
  mount CocomoAdvanced::Engine, :at => '/cocomo_advanced'
  mount BalancingModule::Engine, at: '/balancing_module'
  mount RealSize::Engine, at: '/inputs'

  resources :organization_technologies
  post '/set_technology_uow_synthesis' => 'organizations#set_technology_uow_synthesis', :as => 'set_technology_uow_synthesis'
  get 'change_abacus' => 'organization_technologies#change_abacus', :as => 'change_abacus'

  resources :organization_uow_complexities
  match 'organization_uow_complexities/set_default/:id' => 'organization_uow_complexities#set_default', :as => 'set_default'

  resources :unit_of_works
  resources :attribute_categories

  resources :versions

  resources :reference_values
  resources :wbs_project_elements
  match 'projects/:project_id/wbs_project_elements/:wbs_project_id/change_wbs_project_ratio' => 'wbs_project_elements#change_wbs_project_ratio', :as => 'change_wbs_project_ratio'
  match 'wbs_project_elements/update_wbs_project_ratio_value' => 'wbs_project_elements#update_wbs_project_ratio_value', :as => 'update_wbs_project_ratio_value'

  resources :wbs_activity_ratios do
    collection { match 'wbs_activity_ratios/:wbs_activity_ratio_id/export' => 'wbs_activity_ratios#export', :as => 'export' }
    collection { match 'wbs_activity_ratios/import' => 'wbs_activity_ratios#import', :as => 'import' }
  end
  match 'wbs_activity_ratios/:ratio_id/validate_ratio' => 'wbs_activity_ratios#validate_ratio', :as => 'validate_ratio'
  get 'refresh_ratio_elements' => 'wbs_activities#refresh_ratio_elements', :as => 'refresh_ratio_elements'

  resources :wbs_activity_ratio_elements
  post 'save_values' => 'wbs_activity_ratio_elements#save_values', :as => 'save_values'

  resources :wbs_activity_elements
  match 'wbs_activities/:wbs_activity_id/duplicate_wbs_activity' => 'wbs_activities#duplicate_wbs_activity', :as => :duplicate_wbs_activity
  get 'update_status_collection' => 'wbs_activity_elements#update_status_collection', :as => 'update_status_collection'

  resources :wbs_activities do
    collection { post :import }
  end

  match 'homes/update_install' => 'homes#update_install', :as => 'update_install'
  #match 'homes/testme' => 'homes#testme', :as => 'testme'

  resources :record_statuses

  resources :auth_methods

  resources :admin_settings

  # searches controller routes
  post 'searches/results'
  get 'searches/results' => 'searches#results', :as => 'searches/results'
  match 'searches/results' => 'searches#results', :as => 'search_results'

  resources :project_security_levels

  resources :estimation_values
  match 'estimation_values/:type/convert' => 'estimation_values#convert', :as => 'convert'

  resources :attribute_modules
  post 'check_attribute_modules' => 'attribute_modules#check_attribute_modules', :as => 'check_attribute_modules'

  resources :module_projects
  match 'module_projects/:project_id/pbs_element_matrix' => 'module_projects#pbs_element_matrix', :as => 'pbs_element_matrix'
  match 'module_projects/:project_id/module_projects_matrix' => 'module_projects#module_projects_matrix', :as => 'module_projects_matrix'
  match 'module_projects/associate_modules_projects' => 'module_projects#associate_modules_projects', :as => 'associate_modules_projects'
  match 'module_projects/associate_module_project_to_ratios' => 'module_projects#associate_module_project_to_ratios', :as => 'associate_module_project_to_ratios'
  post 'module_projects/associate'
  match 'module_projects/:module_project_id/activate_module_project' => 'module_projects#activate_module_project', :as => 'activate_module_project'
  get 'selected_balancing_attribute' => 'module_projects#selected_balancing_attribute', :as => 'selected_balancing_attribute'
  get 'show_module_project_results_view' => 'module_projects#show_module_project_results_view', :as => 'show_module_project_results_view'

  resources :languages

  resources :project_securities
  get 'select_users' => 'project_securities#select_users', :as => 'select_users'

  resources :pe_attributes
  post 'check_attribute' => 'pe_attributes#check_attribute', :as => 'check_attribute'
  get 'find_use_attribute' => 'pe_attributes#find_use_attribute', :as => 'find_use_attribute'

  resources :work_element_types

  resources :currencies

  resources :organizations do
    resources :fields
    resources :wbs_activities
    resources :groups
    resources :project_categories
    resources :platform_categories
    resources :acquisition_categories
    resources :project_areas
  end
  get 'organizationals_params' => 'organizations#organizationals_params', :as => 'organizationals_params'
  post '/set_technology_size_type_abacus' => 'organizations#set_technology_size_type_abacus', :as => 'set_technology_size_type_abacus'
  post '/set_technology_size_unit_abacus' => 'organizations#set_technology_size_unit_abacus', :as => 'set_technology_size_unit_abacus'
  post '/organizations/:organization_id/export' => 'organizations#export', :as => 'export_organization'
  match 'organizations/:organization_id/duplicate_organization' => 'organizations#duplicate_organization', :as => :duplicate_organization

  resources :subcontractors
  #match '/subcontractors', :to => 'subcontractors#new', :via => :get, :as => :get_subcontractor
  #match 'subcontractors/:id/edit' => 'subcontractors#update', :via => :put, :as => :put_subcontractor

  resources :labor_categories

  resources :event_types

  resources :events

  resources :permissions
  post 'set_rights' => 'permissions#set_rights', :as => 'set_rights'
  post 'set_rights_project_security' => 'permissions#set_rights_project_security', :as => 'set_rights_project_security'
  get 'globals_permissions' => 'permissions#globals_permissions', :as => 'globals_permissions'

  resources :groups
  post 'update_selected_users' => 'groups#update_selected_users'
  post 'update_selected_projects' => 'groups#update_selected_projects'

  resources :pemodules
  match 'pemodules/:module_id/pemodules_down' => 'pemodules#pemodules_down', :as => 'pemodules_down'
  match 'pemodules/:module_id/pemodules_up' => 'pemodules#pemodules_up', :as => 'pemodules_up'
  match 'pemodules/:module_id/pemodules_left' => 'pemodules#pemodules_left', :as => 'pemodules_left'
  match 'pemodules/:module_id/pemodules_right' => 'pemodules#pemodules_right', :as => 'pemodules_right'

  get 'list_attributes' => 'pemodules#list_attributes'
  get 'update_selected_attributes' => 'pemodules#update_selected_attributes'
  post 'set_attributes_module' => 'pemodules#set_attributes_module'
  get 'estimations_params' => 'pemodules#estimations_params', :as => 'estimations_params'
  get 'find_use_pemodule' => 'pemodules#find_use_pemodule', :as => 'find_use_pemodule'

  resources :groups
  get 'associated_user' => 'groups#associated_user', :as => 'associated_user'

  resources :pbs_project_elements
  get 'new' => 'pbs_project_elements#new'
  get 'up' => 'pbs_project_elements#up'
  get 'down' => 'pbs_project_elements#down'
  get 'selected_pbs_project_element' => 'pbs_project_elements#selected_pbs_project_element'
  get 'refresh_pbs_activity_ratios' => 'pbs_project_elements#refresh_pbs_activity_ratios', :as => 'refresh_pbs_activity_ratios'

  resources :pe_wbs_projects

  resources :projects
  match 'dashboard/:project_id/' => 'projects#dashboard', :as => 'dashboard'

  get 'append_pemodule' => 'projects#append_pemodule'
  get 'select_categories' => 'projects#select_categories', :as => 'select_categories'
  post 'run_estimation' => 'projects#run_estimation', :as => 'run_estimation'

  get 'show_estimation_graph' => 'projects#show_estimation_graph', :as => 'show_estimation_graph'
  get 'show_module_configuration' => 'projects#show_module_configuration', :as => 'show_module_configuration'

  get 'results_with_activities_by_profile' => 'projects#results_with_activities_by_profile', :as => 'results_with_activities_by_profile'
  get 'load_security_for_selected_user' => 'projects#load_security_for_selected_user', :as => 'load_security_for_selected_user'
  get 'load_security_for_selected_group' => 'projects#load_security_for_selected_group', :as => 'load_security_for_selected_group'
  get 'update_project_security_level' => 'projects#update_project_security_level', :as => 'update_project_security_level'
  get 'update_project_security_level_group' => 'projects#update_project_security_level_group', :as => 'update_project_security_level_group'
  get 'projects_global_params' => 'projects#projects_global_params', :as => 'projects_global_params'
  get 'commit' => 'projects#commit', :as => 'commit'
  get 'activate' => 'projects#activate', :as => 'activate'
  get 'activate_project' => 'projects#activate', :as => 'activate_project'
  match 'projects/:project_id/choose_project' => 'projects#choose_project', :as => 'choose_project'
  get 'find_use_project' => 'projects#find_use_project', :as => 'find_use_project'
  get 'check_in' => 'projects#check_in', :as => 'check_in'
  get 'check_out' => 'projects#check_out', :as => 'check_out'
  get 'select_pbs_project_elements' => 'projects#select_pbs_project_elements', :as => 'select_pbs_project_elements'
  get 'add_filter_on_project_version' => 'projects#add_filter_on_project_version', :as => 'add_filter_on_project_version'
  get 'checkout' => 'projects#checkout', :as => 'checkout'
  get 'collapse_project_version' => 'projects#collapse_project_version', :as => 'collapse_project_version'
  get 'update_organization_estimation_statuses' => 'projects#update_organization_estimation_statuses', as: 'update_organization_estimation_statuses'
  get 'add_comment_on_status_change' => 'projects#add_comment_on_status_change', as: 'add_comment_on_status_change'

  match 'update_comments_status_change' => 'projects#update_comments_status_change', as: 'update_comments_status_change'
  post 'add_wbs_activity_to_project' => 'projects#add_wbs_activity_to_project',  :as => 'add_wbs_activity_to_project'
  post 'update_project_security_level_group' => 'projects#update_project_security_level_group',  :as => 'update_project_security_level_group'
  post 'update_project_security_level' => 'projects#update_project_security_level',  :as => 'update_project_security_level'

  get 'refresh_wbs_project_elements' => 'projects#refresh_wbs_project_elements', :as => 'refresh_wbs_project_elements'
  get 'refresh_wbs_activity_ratios' => 'projects#refresh_wbs_activity_ratios',   :as => 'refresh_wbs_activity_ratios'
  get 'generate_wbs_project_elt_tree' => 'projects#generate_wbs_project_elt_tree', :as => 'generate_wbs_project_elt_tree'
  get 'render_selected_wbs_activity_elements' => 'projects#render_selected_wbs_activity_elements', as: 'render_selected_wbs_activity_elements'
  match 'projects/:id/display_estimation_plan' => 'projects#display_estimation_plan', :as => 'display_estimation_plan'

  match 'projects/:project_id/duplicate' => 'projects#duplicate', :as => :duplicate
  match 'projects/:project_id/confirm_deletion' => 'projects#confirm_deletion', :as => :confirm_deletion
  match 'projects/:project_id/locked_plan' => 'projects#locked_plan', :as => :locked_plan
  get 'show_project_history' => 'projects#show_project_history', :as => :show_project_history

  get 'projects_from' => 'projects#projects_from', :as => 'projects_from'
  post 'load_setting_module/:module_project_id' => 'projects#load_setting_module', :as => 'load_setting_module'

  #Master Data validation and restoration routes
  match ':controller/:id/validate_change' => ':controller#validate_change', :as => 'validate_change'
  match ':controller/:id/restore_change' => ':controller#restore_change', :as => 'restore_change'

  match 'wbs_activities/:id/validate_change_with_children' => 'wbs_activities#validate_change_with_children', :as => 'validate_change_with_children'
  post 'save_wbs_activity_ratio_per_profile' => 'wbs_activity_ratio_elements#save_wbs_activity_ratio_per_profile', :as => 'save_wbs_activity_ratio_per_profile'

  resources :translations
  get 'load_translations' => 'translations#load_translations', :as => 'load_translations'

  post 'update_selected_attribute_organizations' => 'attribute_organizations#update_selected_attribute_organizations'
  post 'save_cocomo_basic' => 'cocomo_basics#save_cocomo_basic', :as => 'EstimationControllers/save_cocomo_basic'

  root :to => 'projects#index'
end
