class Purchase < ApplicationRecord
  belongs_to :product, optional: true
  belongs_to :seller, class_name: "User", inverse_of: :sold_purchases
  belongs_to :buyer, class_name: "User", inverse_of: :bought_purchases

  validates :product_name, :price, :quantity, presence: true
  validates :price, :quantity, numericality: {greater_than_or_equal_to: 0, only_integer: true}
  validates :product, presence: true, on: :create
  validate :buyer_seller

  private

  def buyer_seller
    if buyer_id == seller_id
      errors.add(:seller, "can't be buyer")
    end
  end
end
