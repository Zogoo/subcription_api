# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :webhooks, defaults: { format: :json } do
    post 'stripe/create'
  end
end
