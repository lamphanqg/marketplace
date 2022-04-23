class V1::UsersController < ApplicationController
  skip_before_action :authenticate, only: [:create]

  # GET /v1/users
  def index
    users = User.order(:id)
    render json: users, status: :ok
  end

  # GET /v1/users/:id
  def show
    user = User.find(params[:id])
    render json: user, status: :ok
  end

  # POST /v1/users
  def create
    user = User.new(user_params)
    if user.save
      render json: user, status: :created
    else
      render json: {errors: user.errors}, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email, :password)
  end
end
