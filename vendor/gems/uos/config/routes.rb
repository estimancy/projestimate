Uos::Engine.routes.draw do
  root :to => 'inputs#index'
  post 'save_uos' => 'inputs#save_uos', :as => 'save_uos'
  get 'load_gross' => 'inputs#load_gross', :as => 'load_gross'
  get 'update_complexity_select_box' => 'inputs#update_complexity_select_box', :as => 'update_complexity_select_box'

  get 'new_item/:mp' => 'inputs#new_item', :as => 'new_item'
  get 'remove_item' => 'inputs#new_item', :as => 'remove_item'
end