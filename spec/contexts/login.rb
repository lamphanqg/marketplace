RSpec.shared_context "when logged in" do
  let(:login_token) do
    post "/v1/login", params: {email: email, password: password}
    JSON.parse(response.body)["token"]
  end
end
