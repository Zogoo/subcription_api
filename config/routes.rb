Rails.application.routes.draw do
  namespace :webhooks do
    post 'stripe/create'
  end
end
