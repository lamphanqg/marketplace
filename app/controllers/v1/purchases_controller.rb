class V1::PurchasesController < ApplicationController
  def create
    product = Product.find(params[:product_id])

    begin
      ActiveRecord::Base.transaction do
        purchase = Purchase.create!(
          product: product,
          product_name: product.name,
          quantity: params[:quantity].to_i,
          price: product.price,
          buyer: @current_user,
          seller: product.seller
        )
        product.lock!
        product.update!(quantity: product.quantity - params[:quantity].to_i)
        render json: purchase, status: :created
      end
    rescue ActiveRecord::RecordInvalid => e
      render json: {errors: e.record.errors}, status: :unprocessable_entity
    end
  end

  def my_purchases
    purchases = @current_user.bought_purchases.order(created_at: :desc)
    render json: purchases, status: :ok
  end
end
