RealSize::Engine.routes.draw do
  root :to => 'inputs#index'
  post 'save' => 'inputs#save', :as => 'save'
  get "/inputs" => "inputs#index", as: 'inputs'
end
