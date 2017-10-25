Rails.application.routes.draw do
  root 'attractions#index'

  devise_for :users

  resources :attractions do
    collection do
      get 'list'
      post 'import'
      post 'reset'
      post 'download_locations'
    end

    member do
      post 'must_see'
      post 'visited'
    end
  end
end
