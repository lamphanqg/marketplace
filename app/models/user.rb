class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true,
    format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, presence: true
  validates :point, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  has_many :products, dependent: :destroy,
    inverse_of: :seller, foreign_key: :seller_id

  def as_json(options = {})
    excluding = [options[:except]].flatten.compact.union([:password_digest])
    super(options.merge(except: excluding))
  end
end
