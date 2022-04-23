class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true,
    format: {with: URI::MailTo::EMAIL_REGEXP}
  validates :password, presence: true

  def as_json(options = {})
    excluding = [options[:except]].flatten.compact.union([:password_digest])
    super(options.merge(except: excluding))
  end
end
