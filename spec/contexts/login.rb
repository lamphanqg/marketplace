RSpec.shared_context "when logged in" do
  let(:login_token) {
    post "/v1/login", params: {email: "login_user@example.com", password: "Test12345"}
    JSON.parse(response.body)["token"]
  }

  before do
    User.create!(email: "login_user@example.com", password: "Test12345")
  end
end
