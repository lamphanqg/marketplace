RSpec.shared_examples "an unauthenticated action" do
  it "returns unauthorized header" do
    expect(response).to have_http_status(:unauthorized)
  end
end
