Dummy::Application.routes.draw do
  root to: "home#index"

  resources :products do
    resources :comments
  end

  resources :blog_posts
end