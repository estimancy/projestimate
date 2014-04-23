Uos::Engine.routes.draw do
  root :to => 'inputs#index'
  post 'save_uos' => 'inputs#save_uos', :as => 'save_uos'
  get 'load_gross' => 'inputs#load_gross', :as => 'load_gross'
  get 'update_complexity_select_box' => 'inputs#update_complexity_select_box', :as => 'update_complexity_select_box'

  get 'new_item/:mp/:pbs_id' => 'inputs#new_item', :as => 'new_item'
  get 'remove_item/:input_id' => 'inputs#remove_item', :as => 'remove_item'

  get 'export/:mp/:pbs_id' => 'inputs#export', :as => 'export'
  post 'import/:mp/:pbs_id' => 'inputs#import', :as => 'import'
end