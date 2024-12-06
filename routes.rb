# frozen_string_literal: true

require_relative 'router'

Router.draw do
  get '/', 'BaseController#call'
  get '/test', 'BaseController#test'
  get '/users', 'UsersController#index'
  get '/users/:id', 'UsersController#show'
  get '/articles/:article_id/comments', 'CommentsController#index'
end
