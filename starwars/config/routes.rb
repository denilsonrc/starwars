Rails.application.routes.draw do
  root 'people#index'
  get 'people/index', to: 'people#index', as: "people_index"
  get 'people/show:id', to: 'people#show', as: "people_show"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
