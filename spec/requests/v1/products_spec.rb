require "rails_helper"
require "contexts/login"
require "examples/authenticate"

RSpec.describe "V1::Products", type: :request do
  let(:sellers) do
    (0..4).map do |i|
      User.create!(email: "seller#{i}@example.com", password: "Test12345")
    end
  end
  let(:products) do
    (0..4).map do |i|
      Product.create!(name: "product #{i}", seller: sellers.sample, price: rand(10_000), quantity: rand(100))
    end
  end
  let(:json) { JSON.parse(response.body) }

  describe "GET /v1/products" do
    it "returns all products in price asc order" do
      products_by_price = products.sort_by { |prod| prod.price }
      get "/v1/products"
      expect(response).to have_http_status(:ok)
      expect(json.map { |product| product["id"] }).to eq(products_by_price.map(&:id))
    end
  end

  describe "GET /v1/products/:id" do
    it "returns a product" do
      product = sellers.first.products.create!(name: "test product", quantity: 5, price: 3000)
      get "/v1/products/#{product.id}"
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(product.id)
    end

    it "raises exception RecordNotFound if product not exist" do
      expect {
        get "/v1/products/10000"
      }.to raise_exception(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET /v1/my_products" do
    context "with authenticated user" do
      let(:seller) { products[0].seller }

      include_context "when logged in" do
        let(:email) { seller.email }
        let(:password) { "Test12345" }
      end

      it "returns seller's product list in price asc order" do
        get "/v1/my_products", headers: {"Authorization" => login_token}
        expect(response).to have_http_status(:ok)
        products_by_price = seller.products.sort_by { |prod| prod.price }
        expect(json.map { |prod| prod["id"] }).to eq(products_by_price.map(&:id))
      end
    end

    context "without authenticated user" do
      before { get "/v1/my_products" }

      it_behaves_like "an unauthenticated action"
    end
  end

  describe "POST /v1/products" do
    context "with authenticated user" do
      let(:seller) { sellers.sample }

      include_context "when logged in" do
        let(:email) { seller.email }
        let(:password) { "Test12345" }
      end

      it "creates a product" do
        old_count = Product.count
        post "/v1/products", headers: {"Authorization" => login_token},
          params: {name: "test", quantity: 5, price: 100}
        expect(response).to have_http_status(:created)
        expect(Product.count).to be(old_count + 1)
      end

      it "returns errors with invalid data" do
        post "/v1/products", headers: {"Authorization" => login_token},
          params: {name: "test", quantity: -5, price: 100.5}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"].keys).to include("quantity", "price")
      end
    end

    context "without authenticated user" do
      before do
        post "/v1/products", params: {name: "test product", quantity: 3, price: 100}
      end

      it_behaves_like "an unauthenticated action"
    end
  end

  describe "PATCH /v1/products/:id" do
    let(:product) { products.sample }

    context "with authenticated user" do
      let(:seller) { product.seller }

      include_context "when logged in" do
        let(:email) { seller.email }
        let(:password) { "Test12345" }
      end

      it "updates a product" do
        patch "/v1/products/#{product.id}", headers: {"Authorization" => login_token},
          params: {name: "changed name"}
        expect(response).to have_http_status(:ok)
        after = Product.find(product.id)
        expect(after.name).to eq("changed name")
      end

      it "ignores quantity param" do
        patch "/v1/products/#{product.id}", headers: {"Authorization" => login_token},
          params: {quantity: 300}
        expect(response).to have_http_status(:ok)
        after = Product.find(product.id)
        expect(after.quantity).to eq(product.quantity)
      end

      it "returns errors with invalid data" do
        patch "/v1/products/#{product.id}", headers: {"Authorization" => login_token},
          params: {price: -20_000}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"].keys).to include("price")
      end
    end

    context "without authenticated user" do
      before do
        patch "/v1/products/#{product.id}", params: {price: 100}
      end

      it_behaves_like "an unauthenticated action"
    end
  end

  describe "PATCH /v1/products/:id/add_quantity" do
    let(:product) { products.sample }

    context "with authenticated user" do
      let(:seller) { product.seller }

      include_context "when logged in" do
        let(:email) { seller.email }
        let(:password) { "Test12345" }
      end

      it "adds quantity to product" do
        patch "/v1/products/#{product.id}/add_quantity", headers: {"Authorization" => login_token},
          params: {add: 200}
        expect(response).to have_http_status(:ok)
        expect(json["quantity"]).to be(product.quantity + 200)
      end

      it "subtract quantity from product if pass negative value" do
        subtr = product.quantity / 2
        patch "/v1/products/#{product.id}/add_quantity", headers: {"Authorization" => login_token},
          params: {add: -subtr}
        expect(response).to have_http_status(:ok)
        expect(json["quantity"]).to be(product.quantity - subtr)
      end

      it "cannot subtract to negative value" do
        subtr = product.quantity + 1
        patch "/v1/products/#{product.id}/add_quantity", headers: {"Authorization" => login_token},
          params: {add: -subtr}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json["errors"]).to include("quantity")
      end

      # TODO
      it "uses pessimistic lock while updating"
    end

    context "without authenticated user" do
      before do
        patch "/v1/products/#{product.id}/add_quantity", params: {add: 100}
      end

      it_behaves_like "an unauthenticated action"
    end
  end

  describe "DELETE /v1/products/:id" do
    let!(:product) { products.sample }

    context "with authenticated user" do
      let(:seller) { product.seller }

      include_context "when logged in" do
        let(:email) { seller.email }
        let(:password) { "Test12345" }
      end

      it "deletes product" do
        count = Product.count
        delete "/v1/products/#{product.id}", headers: {"Authorization" => login_token}
        expect(response).to have_http_status(:ok)
        expect(Product.count).to eq(count - 1)
      end

      it "cannot delete other seller's product" do
        other_product = Product.where.not(seller: seller).first
        expect {
          delete "/v1/products/#{other_product.id}", headers: {"Authorization" => login_token}
        }.to raise_exception(ActiveRecord::RecordNotFound)
      end
    end

    context "without authenticated user" do
      before do
        delete "/v1/products/#{product.id}"
      end

      it_behaves_like "an unauthenticated action"
    end
  end
end
