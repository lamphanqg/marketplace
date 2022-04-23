require "rails_helper"

RSpec.describe "V1::Authentication", type: :request do
  describe "POST /v1/login" do
    before do
      User.create!(email: "test@example.com", password: "Test12345")
    end

    context "with valid email/password" do
      it "returns token" do
        post "/v1/login", params: {email: "test@example.com", password: "Test12345"}
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["token"]).to be_truthy
      end
    end

    context "with wrong password" do
      it "returns unauthorized header" do
        post "/v1/login", params: {email: "test@example.com", password: "Test"}
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
