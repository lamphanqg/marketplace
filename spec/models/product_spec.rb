require "rails_helper"

RSpec.describe Product, type: :model do
  let(:seller) { User.create!(email: "test@example.com", password: "Test12345") }

  it "is valid with name, seller, quantity, price" do
    product = described_class.new(name: "product 1", seller: seller, quantity: 1, price: 500)
    expect(product).to be_valid
  end

  it "is invalid without seller" do
    product = described_class.new(name: "product 1", quantity: 1, price: 500)
    product.valid?
    expect(product.errors[:seller]).to include("must exist")
  end

  it "is invalid without quantity" do
    product = described_class.new(name: "product 1", seller: seller, price: 500)
    product.valid?
    expect(product.errors[:quantity]).to include("can't be blank")
  end

  it "is invalid without price" do
    product = described_class.new(name: "product 1", seller: seller, quantity: 1)
    product.valid?
    expect(product.errors[:price]).to include("can't be blank")
  end

  it "is invalid with negative quantity" do
    product = described_class.new(name: "product 1", seller: seller, price: 500, quantity: -1)
    product.valid?
    expect(product.errors[:quantity]).to include("must be greater than or equal to 0")
  end

  it "is invalid with negative price" do
    product = described_class.new(name: "product 1", seller: seller, price: -500, quantity: 1)
    product.valid?
    expect(product.errors[:price]).to include("must be greater than or equal to 0")
  end

  it "is invalid with decimal quantity" do
    product = described_class.new(name: "product 1", seller: seller, price: 500, quantity: 1.5)
    product.valid?
    expect(product.errors[:quantity]).to include("must be an integer")
  end

  it "is invalid with decimal price" do
    product = described_class.new(name: "product 1", seller: seller, price: 500.5, quantity: 1)
    product.valid?
    expect(product.errors[:price]).to include("must be an integer")
  end
end
