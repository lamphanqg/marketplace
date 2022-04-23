class ApplicationController < ActionController::API
  include JsonWebToken

  before_action :authenticate

  private

  def authenticate
    token = request.headers["Authorization"]&.split(" ")&.last
    return head :unauthorized if token.nil?

    decoded = jwt_decode(token)
    @current_user = User.find(decoded[:user_id])
  end
end
