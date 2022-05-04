class V1::PurchasesController < ApplicationController
  def create
    product = Product.find(params[:product_id])
    purchase_form = PurchaseForm.new(@current_user, product, params[:quantity].to_i)
    if (purchase = purchase_form.save)
      render json: purchase, status: :created
    else
      render json: {errors: purchase_form.errors}, status: :unprocessable_entity
    end
  end

  def my_purchases
    purchases = @current_user.bought_purchases.order(created_at: :desc)
    render json: purchases, status: :ok
  end
end
