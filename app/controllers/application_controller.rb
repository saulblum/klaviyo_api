class ApplicationController < ActionController::API

  before_action :authorized?

  def authorized?
    render status: :forbidden unless request.headers['Authorization'] == ENV['AUTHORIZATION_KEY']
  end

end
