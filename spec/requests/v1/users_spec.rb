require "rails_helper"
require "contexts/login"
require "examples/authenticate"

RSpec.describe "V1::Users", type: :request do
  let(:user) { User.create!(email: "test@example.com", password: "Test12345") }

  describe "GET /v1/users" do
    let(:path) { "/v1/users" }

    context "with authenticated user" do
      include_context "when logged in" do
        let(:email) { "test@example.com" }
        let(:password) { "Test12345" }
      end

      it "returns user list" do
        user
        get path, headers: {"Authorization" => login_token}
        user_ids = JSON.parse(response.body).map { |user| user["id"] }
        expect(user_ids).to eq(User.order(:id).ids)
      end
    end

    context "without authenticated user" do
      before { get path }

      it_behaves_like "an unauthenticated action"
    end
  end

  describe "GET /v1/users/:id" do
    let(:path) { "/v1/users/#{user.id}" }

    context "with authenticated user" do
      include_context "when logged in" do
        let(:email) { "test@example.com" }
        let(:password) { "Test12345" }
      end

      it "returns user" do
        get path, headers: {"Authorization" => login_token}
        json = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(json["id"]).to eq(user.id)
      end
    end

    context "without authenticated user" do
      before { get path }

      it_behaves_like "an unauthenticated action"
    end
  end

  describe "POST /v1/users" do
    context "with valid email and password" do
      it "adds a user" do
        expect {
          post "/v1/users", params: {email: "test@example.com", password: "Test12345"}
        }.to change(User, :count).by(1)
      end
    end

    context "with invalid email" do
      it "does not add a user" do
        expect {
          post "/v1/users", params: {email: "test@@example.com", password: "Test12345"}
        }.not_to change(User, :count)
      end
    end
  end
end
