require "rails_helper"

RSpec.describe User, type: :model do
  it "is valid with an email and password" do
    user = described_class.new(email: "test@example.com", password: "Test12345")
    expect(user).to be_valid
  end

  it "is invalid without an email" do
    user = described_class.new(password: "Test12345")
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "is invalid with an invalid email format" do
    user = described_class.new(email: "test@@example.com", password: "Test12345")
    user.valid?
    expect(user.errors[:email]).to include("is invalid")
  end

  it "is invalid with a duplicate email" do
    described_class.create!(email: "test@example.com", password: "Test12345")
    user = described_class.new(email: "test@example.com", password: "Test12345")
    user.valid?
    expect(user.errors[:email]).to include("has already been taken")
  end

  it "has 10,000 point as default" do
    user = described_class.new(email: "test@example.com", password: "Test12345")
    expect(user.point).to eq(10_000)
  end

  describe "#as_json" do
    it "does not include password_digest" do
      user = described_class.new(email: "test@example.com", password: "Test12345")
      expect(user.as_json).not_to have_key("password_digest")
    end
  end
end
