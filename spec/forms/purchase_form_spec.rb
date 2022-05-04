require "rails_helper"

RSpec.describe PurchaseForm do
  describe "#save" do
    let(:buyer) { User.create!(email: "buyer@example.com", password: "Test12345") }
    let(:seller) { User.create!(email: "seller@example.com", password: "Test12345") }
    let(:product) { seller.products.create!(name: "test", quantity: 5, price: 1000) }

    context "when data is valid" do
      let!(:old_purchase_count) { Purchase.count }
      let(:valid_form) { described_class.new(buyer, product, 1) }

      it "is valid" do
        expect(valid_form).to be_valid
      end

      it "creates a purchase" do
        valid_form.save
        expect(Purchase.count).to eq(old_purchase_count + 1)
      end

      it "transfers points from buyer to seller" do
        buyer_old_point = buyer.point
        seller_old_point = seller.point
        valid_form.save
        expect(buyer.reload.point).to eq(buyer_old_point - 1000)
        expect(seller.reload.point).to eq(seller_old_point + 1000)
      end

      it "reduces product quantity" do
        old_product_quantity = product.quantity
        valid_form.save
        expect(product.reload.quantity).to eq(old_product_quantity - 1)
      end

      # TODO
      it "uses pessimistic lock on users and products"
    end

    it "is invalid when quantity is greater than product's quantity" do
      form = described_class.new(buyer, product, 10)
      form.valid?
      expect(form.errors[:quantity]).to include("can't be more than product's quantity")
    end
  end
end
