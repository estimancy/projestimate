CocomoExpert::Engine.routes.draw do
  get "input_cocomo/index"
  post "cocomo_save" => "input_cocomo#cocomo_save", :as => "cocomo_save"
  get "input_cocomo/help/:factor_id" => "input_cocomo#help", :as => "help"
  root :to => 'input_cocomo#index'
end
