class Product < ApplicationRecord
  belongs_to :seller, class_name: "User", inverse_of: :products

  validates :name, presence: true
  validates :quantity, :price, presence: true,
    numericality: {only_integer: true, greater_than_or_equal_to: 0}
end
