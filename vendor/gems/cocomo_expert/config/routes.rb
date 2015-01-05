CocomoExpert::Engine.routes.draw do
  get "input_cocomo/index"
  post "cocomo_save" => "input_cocomo#cocomo_save", :as => "cocomo_save"

  get 'add_note_to_factor/:factor_id' => 'input_cocomo#add_note_to_factor', :as => 'add_note_to_factor'
  get 'add_note_to_size' => 'input_cocomo#add_note_to_size', :as => 'add_note_to_size'

  post 'notes_form/:factor_id' => 'input_cocomo#notes_form', :as => 'notes_form'
  post 'notes_form_size' => 'input_cocomo#notes_form_size', :as => 'notes_form_size'

  get "input_cocomo/help/:factor_id" => "input_cocomo#help", :as => "help"
  root :to => 'input_cocomo#index'
end
