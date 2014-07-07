CocomoExpert::Engine.routes.draw do
  get "input_cocomo/index"
  post "cocomo_save" => "input_cocomo#cocomo_save", :as => "cocomo_save"

  get 'add_note_to_factor/:factor_id' => 'input_cocomo#add_note_to_factor', :as => 'add_note_to_factor'
  post 'notes_form/:factor_id' => 'input_cocomo#notes_form', :as => 'notes_form'

  get "input_cocomo/help/:factor_id" => "input_cocomo#help", :as => "help"
  root :to => 'input_cocomo#index'
end
