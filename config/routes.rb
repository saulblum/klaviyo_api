Rails.application.routes.draw do
  get '/sync-orders' => 'orders#sync'
  get '/sync' => 'sync#sync'
end
