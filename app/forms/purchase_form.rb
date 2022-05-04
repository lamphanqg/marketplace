class PurchaseForm
  include ActiveModel::Model

  validate :check_product_quantity

  def initialize(buyer, product, quantity)
    @product = product
    @buyer = buyer
    @seller = product.seller
    @quantity = quantity
  end

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      purchase = Purchase.create!(
        product: @product,
        product_name: @product.name,
        quantity: @quantity,
        price: @product.price,
        buyer: @buyer,
        seller: @seller
      )
      @product.lock!
      @buyer.lock!
      @seller.lock!
      @product.update!(quantity: @product.quantity - @quantity)
      @buyer.update!(point: @buyer.point - @quantity * @product.price)
      @seller.update!(point: @seller.point + @quantity * @product.price)

      purchase
    end
  rescue ActiveRecord::RecordInvalid => e
    e.record.errors.each do |err|
      errors.add(err.attribute, err.message)
    end
    false
  end

  private

  def check_product_quantity
    if @quantity > @product.quantity
      errors.add(:quantity, "can't be more than product's quantity")
    end
  end
end
