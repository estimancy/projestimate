CocomoAdvanced::Engine.routes.draw do
  get "input_cocomo/index"
  get "input_cocomo/help/:factor_id" => "input_cocomo#help", :as => "help"
  post "cocomo_save" => "input_cocomo#cocomo_save", :as => "cocomo_save"
  root :to => 'input_cocomo#index'
end
