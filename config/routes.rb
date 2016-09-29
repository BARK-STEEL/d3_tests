Rails.application.routes.draw do
  root 'deboog#index'

  get '/d3', to: 'd3#index'
  get '/d3_json', to: 'd3#json'
end
