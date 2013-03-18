ProjestimateMaquette::Application.routes.draw do


  resources :ej_estimation_values


  resources :reference_values
  resources :wbs_project_elements

  resources :wbs_activity_ratios do
    collection { match 'wbs_activity_ratios/:wbs_activity_ratio_id/export' => 'wbs_activity_ratios#export', :as => 'export' }
    collection { match 'wbs_activity_ratios/import' => 'wbs_activity_ratios#import', :as => 'import' }
  end
  get 'refresh_ratio_elements' => 'wbs_activities#refresh_ratio_elements', :as => 'refresh_ratio_elements'

  resources :wbs_activity_ratio_elements
  post 'save_values' => 'wbs_activity_ratio_elements#save_values', :as => 'save_values'

  resources :wbs_activity_elements
  match 'wbs_activities/:wbs_activity_id/duplicate_wbs_activity' => 'wbs_activities#duplicate_wbs_activity', :as => :duplicate_wbs_activity
  #match 'wbs_activity_elements/wbs_record_statuses_collection', :as => 'wbs_record_statuses_collection'
  #match 'wbs_activity_elements/update_status_collection/:selected_parent_id', :controller=>'wbs_activity_elements', :action => 'update_status_collection'
  get 'update_status_collection' => 'wbs_activity_elements#update_status_collection', :as => 'update_status_collection'

  resources :wbs_activities do
    collection { post :import }
  end

  match 'homes/update_install' => 'homes#update_install', :as => 'update_install'
  match 'homes/about' => 'homes#about', :as => 'about'

  resources :record_statuses

  resources :peicons
  match 'peicons/:id/choose_icon' => 'peicons#choose_icon', :as => 'choose_icon'

  resources :auth_methods

  resources :admin_settings

  resources :master_settings

  resources :searches
  post "searches/results"
  get "user_search" => "searches#user_search", :as => "user_search"
  get "project_search" => "searches#project_search", :as => "project_search"

  resources :project_security_levels

  resources :module_project_attributes

  resources :attribute_modules

  resources :module_projects
  match 'module_projects/:project_id/pbs_element_matrix' => 'module_projects#pbs_element_matrix', :as => 'pbs_element_matrix'
  match 'module_projects/:project_id/module_projects_matrix' => 'module_projects#module_projects_matrix', :as => 'module_projects_matrix'
  match 'module_projects/associate_modules_projects' => 'module_projects#associate_modules_projects', :as => 'associate_modules_projects'
  post 'module_projects/associate'

  resources :languages

  resources :project_securities
  get "select_users" => "project_securities#select_users", :as => "select_users"

  resources :attributes

  resources :project_categories

  resources :platform_categories

  resources :work_element_types

  resources :activity_categories

  resources :currencies

  resources :organization_labor_categories

  resources :organizations
  get "organizationals_params" => "organizations#organizationals_params", :as => "organizationals_params"

  resources :labor_categories

  resources :acquisition_categories

  resources :project_areas

  resources :event_types

  resources :events

  resources :permissions
  post "set_rights" => "permissions#set_rights", :as => "set_rights"
  post "set_rights_project_security" => "permissions#set_rights_project_security", :as => "set_rights_project_security"
  get "globals_permissions" => "permissions#globals_permissions", :as => "globals_permissions"

  resources :groups

  resources :pemodules
  match 'pemodules/:module_id/pemodules_down' => 'pemodules#pemodules_down', :as => 'pemodules_down'
  match 'pemodules/:module_id/pemodules_up' => 'pemodules#pemodules_up', :as => 'pemodules_up'
  match 'pemodules/:module_id/pemodules_left' => 'pemodules#pemodules_left', :as => 'pemodules_left'
  match 'pemodules/:module_id/pemodules_right' => 'pemodules#pemodules_right', :as => 'pemodules_right'

  get "list_attributes" => "pemodules#list_attributes"
  get "update_selected_attributes" => "pemodules#update_selected_attributes"
  post "set_attributes_module" => "pemodules#set_attributes_module"
  get "estimations_params" => "pemodules#estimations_params", :as => "estimations_params"
  get "export_to_pdf" => "pemodules#export_to_pdf"

  resources :groups
  get "associated_user" => "groups#associated_user" , :as => "associated_user"

  resources :pbs_project_elements
  get "new" => "pbs_project_elements#new"
  get "up" => "pbs_project_elements#up"
  get "down" => "pbs_project_elements#down"
  get "selected_pbs_project_element" => "pbs_project_elements#selected_pbs_project_element"

  resources :pe_wbs_projects

  resources :projects
  get "add_module" => "projects#add_module"
  get "add_your_integrated_module" => "projects#add_your_integrated_module"
  get "select_categories" => "projects#select_categories", :as => "select_categories"
  post "run_estimation" => "projects#run_estimation", :as => "run_estimation"
  get "load_security_for_selected_user" => "projects#load_security_for_selected_user", :as => "load_security_for_selected_user"
  get "load_security_for_selected_group" => "projects#load_security_for_selected_group", :as => "load_security_for_selected_group"
  get "update_project_security_level" => "projects#update_project_security_level", :as => "update_project_security_level"
  get "update_project_security_level_group" => "projects#update_project_security_level_group", :as => "update_project_security_level_group"
  get "projects_global_params" => "projects#projects_global_params", :as => "projects_global_params"
  get "change_selected_project" => "projects#change_selected_project" , :as => "change_selected_project"
  get "commit" => "projects#commit" , :as => "commit"
  get "activate" => "projects#activate" , :as => "activate"
  get "find_use" => "projects#find_use" , :as => "find_use"
  get "check_in" => "projects#check_in" , :as => "check_in"
  get "check_out" => "projects#check_out" , :as => "check_out"
  get "project_record_number" => "projects#project_record_number", :as => "project_record_number"
  get "select_pbs_project_elements" => "projects#select_pbs_project_elements", :as => "select_pbs_project_elements"

  post 'add_wbs_activity_to_project' => 'projects#add_wbs_activity_to_project', :as => 'add_wbs_activity_to_project'
  get 'refresh_wbs_project_elements' => 'projects#refresh_wbs_project_elements', :as => 'refresh_wbs_project_elements'
  get 'generate_wbs_project_elt_tree' => 'projects#generate_wbs_project_elt_tree', :as => 'generate_wbs_project_elt_tree'

  match 'projects/:project_id/duplicate' => 'projects#duplicate', :as => :duplicate

  resources :users
  get "dashboard" => "users#show", :as => "dashboard"
  get "sign_up" => "users#new", :as => "sign_up"
  get "validate" => "users#validate", :as => "validate"
  post "create_inactive_user" => "users#create_inactive_user", :as => "create_inactive_user"
  get "find_use_user" => "users#find_use_user" , :as => "find_use_user"
  get "about" => "users#about" , :as => "about"
  match 'users/:id/activate' => 'users#activate', :as => 'activate'
  get "display_states" => "users#display_states", :as => "display_states"

  resources :password_resets

  resources :sessions
  get "log_in" => "sessions#new", :as => "log_in"
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "ask_new_account"  => "sessions#ask_new_account", :as => "ask_new_account"
  get "help_login" => "sessions#help_login", :as => "help_login"
  get "forgotten_password" => "sessions#forgotten_password", :as => "forgotten_password"
  post "reset_forgotten_password" => "sessions#reset_forgotten_password", :as => "reset_forgotten_password"

  #Master Data validation and restoration routes
  match ':controller/:id/validate_change' => ':controller#validate_change', :as => 'validate_change'
  match ':controller/:id/restore_change' => ':controller#restore_change', :as => 'restore_change'

  match 'wbs_activities/:id/validate_change_with_children' => 'wbs_activities#validate_change_with_children', :as => 'validate_change_with_children'

  resources :translations
  get "load_translations" => "translations#load_translations", :as => "load_translations"

  post "save_cocomo_basic" => "cocomo_basics#save_cocomo_basic", :as => "EstimationControllers/save_cocomo_basic"

  root :to => "users#show"
end
