require "rails_helper"
require "contexts/login"
require "examples/authenticate"

RSpec.describe "V1::Purchases", type: :request do
  let(:buyer) { User.create!(email: "buyer@example.com", password: "Test12345") }
  let(:seller) { User.create!(email: "seller@example.com", password: "Test12345") }
  let(:product) { seller.products.create!(name: "Product", price: 1000, quantity: 5) }
  let(:json) { JSON.parse(response.body) }

  describe "POST /v1/purchases" do
    context "with authenticated user" do
      include_context "when logged in" do
        let(:email) { buyer.email }
        let(:password) { "Test12345" }
      end

      context "with valid data" do
        let!(:old_product_quantity) { product.quantity }
        let!(:old_purchase_count) { Purchase.count }

        it "creates a purchase" do
          post "/v1/purchases", headers: {"Authorization" => login_token},
            params: {product_id: product.id, quantity: 2}
          expect(response).to have_http_status(:created)
          expect(Purchase.count).to eq(old_purchase_count + 1)
          expect(product.reload.quantity).to be(old_product_quantity - 2)
        end
      end

      it "return error when data is invalid" do
        post "/v1/purchases", headers: {"Authorization" => login_token},
          params: {product_id: product.id, quantity: 10}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"]["quantity"]).to include("can't be more than product's quantity")
      end

      it "cannot buy product which doesn't exist" do
        expect {
          post "/v1/purchases", headers: {"Authorization" => login_token},
            params: {product_id: 12345, quantity: 1}
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context "without authenticated user" do
      before do
        post "/v1/purchases", params: {product_id: product.id, quantiy: 1}
      end

      it_behaves_like "an unauthenticated action"
    end
  end

  describe "GET /v1/my_purchases" do
    context "with authenticated user" do
      let!(:purchase1) do
        Purchase.create!(product_name: "test 1", quantity: 3,
          price: 500, buyer: buyer, seller: seller, product: product)
      end
      let!(:purchase2) do
        Purchase.create!(product_name: "test 2", quantity: 2,
          price: 500, buyer: buyer, seller: seller, product: product)
      end

      include_context "when logged in" do
        let(:email) { buyer.email }
        let(:password) { "Test12345" }
      end

      it "returns buyer's purchase list in created_at desc order" do
        get "/v1/my_purchases", headers: {"Authorization" => login_token}
        expect(response).to have_http_status(:ok)
        expect(json).to eq([purchase2, purchase1].as_json)
      end
    end

    context "without authenticated user" do
      before do
        get "/v1/my_purchases"
      end

      it_behaves_like "an unauthenticated action"
    end
  end
end
