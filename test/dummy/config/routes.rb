Rails.application.routes.draw do
  root to: 'welcomes#index'
  
  mount Zaiku::Engine => "/zaiku"
end
