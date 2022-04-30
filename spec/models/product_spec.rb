require "rails_helper"

RSpec.describe Product, type: :model do
  let(:seller) { User.create!(email: "test@example.com", password: "Test12345") }
  let(:product) { described_class.new(name: "product 1", seller: seller, quantity: 1, price: 500) }

  it "is valid with name, seller, quantity, price" do
    expect(product).to be_valid
  end

  it "is invalid without seller" do
    product.seller = nil
    product.valid?
    expect(product.errors[:seller]).to include("must exist")
  end

  it "is invalid without quantity" do
    product.quantity = nil
    product.valid?
    expect(product.errors[:quantity]).to include("can't be blank")
  end

  it "is invalid without price" do
    product.price = nil
    product.valid?
    expect(product.errors[:price]).to include("can't be blank")
  end

  it "is invalid with negative quantity" do
    product.quantity = -1
    product.valid?
    expect(product.errors[:quantity]).to include("must be greater than or equal to 0")
  end

  it "is invalid with negative price" do
    product.price = -500
    product.valid?
    expect(product.errors[:price]).to include("must be greater than or equal to 0")
  end

  it "is invalid with decimal quantity" do
    product.quantity = 1.5
    product.valid?
    expect(product.errors[:quantity]).to include("must be an integer")
  end

  it "is invalid with decimal price" do
    product.price = 500.5
    product.valid?
    expect(product.errors[:price]).to include("must be an integer")
  end

  it "nullifies product_id on purchases when deleted" do
    buyer = User.create!(email: "buyer@example.com", password: "Test12345")
    Purchase.create!(product: product, quantity: 1, product_name: product.name,
      price: product.price, buyer: buyer, seller: seller)
    product.destroy!
    expect(Purchase.last.product_id).to be_nil
  end
end
