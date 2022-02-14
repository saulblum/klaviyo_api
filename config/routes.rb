Rails.application.routes.draw do
  get '/sync-orders' => 'orders#sync'
  get '/random-orders' => 'random#sync'
end
