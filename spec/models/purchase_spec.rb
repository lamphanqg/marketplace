require "rails_helper"

RSpec.describe Purchase, type: :model do
  let(:buyer) { User.create!(email: "user1@example.com", password: "Test12345") }
  let(:seller) { User.create!(email: "user2@example.com", password: "Test12345") }
  let(:product) { seller.products.create!(name: "test", price: 500, quantity: 10) }
  let(:base_attrs) do
    {
      product_name: product.name, price: product.price,
      quantity: 1, seller: seller, buyer: buyer, product: product
    }
  end

  it "is valid with product, product name, price, quantity, seller, buyer" do
    purchase = described_class.new(base_attrs)
    expect(purchase).to be_valid
  end

  it "is invalid without product name" do
    test_presence(:product_name)
  end

  it "is invalid without price" do
    test_presence(:price)
  end

  it "is invalid without quantity" do
    test_presence(:quantity)
  end

  it "is invalid without product" do
    test_presence(:product)
  end

  it "is invalid without seller" do
    test_required_belongs_to(:seller)
  end

  it "is invalid without buyer" do
    test_required_belongs_to(:buyer)
  end

  it "is invalid with negative quantity" do
    test_negative(:quantity)
  end

  it "is invalid with negative price" do
    test_negative(:price)
  end

  it "is invalid with decimal quantity" do
    test_decimal(:quantity)
  end

  it "is invalid with decimal price" do
    test_decimal(:price)
  end

  it "is invalid with buyer and seller are same" do
    base_attrs[:seller] = buyer
    purchase = described_class.new(base_attrs)
    purchase.valid?
    expect(purchase.errors[:seller]).to include("can't be buyer")
  end

  it "is invalid with quantity greater than product's quantity" do
    base_attrs[:quantity] = product.quantity + 1
    base_attrs[:product] = product
    purchase = described_class.new(base_attrs)
    purchase.valid?
    expect(purchase.errors[:quantity]).to include("can't be more than product's quantity")
  end

  def test_presence(attr)
    purchase = setup_object_except(attr)
    purchase.valid?
    expect(purchase.errors[attr]).to include("can't be blank")
  end

  def test_required_belongs_to(attr)
    purchase = setup_object_except(attr)
    purchase.valid?
    expect(purchase.errors[attr]).to include("must exist")
  end

  def setup_object_except(attr)
    described_class.new(base_attrs.except(attr))
  end

  def test_negative(attr)
    base_attrs[attr] = -10
    purchase = described_class.new(base_attrs)
    purchase.valid?
    expect(purchase.errors[attr]).to include("must be greater than or equal to 0")
  end

  def test_decimal(attr)
    base_attrs[attr] = 10.5
    purchase = described_class.new(base_attrs)
    purchase.valid?
    expect(purchase.errors[attr]).to include("must be an integer")
  end
end
