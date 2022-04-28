class V1::ProductsController < ApplicationController
  skip_before_action :authenticate, only: [:index, :show]
  before_action :set_product, only: [:update, :add_quantity, :destroy]

  # GET /v1/products
  def index
    products = Product.order(:price)
    render json: products, status: :ok
  end

  # GET /v1/products/:id
  def show
    product = Product.find(params[:id])
    render json: product, status: :ok
  end

  # GET /v1/my_products
  def my_products
    products = @current_user.products.order(:price)
    render json: products, status: :ok
  end

  # POST /v1/products
  def create
    product = @current_user.products.build(product_create_params)
    if product.save
      render json: product, status: :created
    else
      render json: {errors: product.errors}, status: :unprocessable_entity
    end
  end

  # PATCH /v1/products/:id
  def update
    if @product.update(product_update_params)
      render json: @product, status: :ok
    else
      render json: {errors: @product.errors}, status: :unprocessable_entity
    end
  end

  # PATCH /v1/products/:id/add_quantity
  def add_quantity
    @product.with_lock do
      @product.quantity += params[:add].to_i
      @product.save!
    end
    render json: @product, status: :ok
  rescue ActiveRecord::RecordInvalid
    render json: {errors: @product.errors}, status: :unprocessable_entity
  end

  # DELETE /v1/products/:id
  def destroy
    @product.destroy!
    head :ok
  end

  private

  def product_create_params
    params.permit(:name, :price, :quantity)
  end

  def product_update_params
    params.permit(:name, :price)
  end

  def set_product
    @product = @current_user.products.find(params[:id])
  end
end
