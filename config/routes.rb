Rails.application.routes.draw do
  get '/sync-orders' => 'orders#sync'
end
