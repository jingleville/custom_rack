# frozen_string_literal: true

require_relative 'router'

Router.draw do
  get '/', 'BaseController#call'
  get '/test', 'BaseController#test'
  get '/users', 'UsersController#index'
  get '/users/:id', 'UsersController#show'
  get '/articles/:article_id/comments', 'CommentsController#index'

  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end
end
