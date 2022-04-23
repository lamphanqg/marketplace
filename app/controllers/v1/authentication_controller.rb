class V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate

  # POST /v1/login
  def login
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      token = jwt_encode(user_id: @user.id)
      render json: {token: token}, status: :ok
    else
      head :unauthorized
    end
  end

  # TODO Implement logout by adding logged out tokens to blacklist.
  # Blacklist can be stored in Redis tooptimize performance.
  # def logout
  # end
end
