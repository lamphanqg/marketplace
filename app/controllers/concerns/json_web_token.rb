module JsonWebToken
  extend ActiveSupport::Concern
  SECRET_KEY = Rails.application.secret_key_base

  def jwt_encode(payload, exp = 1.day.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, "HS256")
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: "HS256")[0]
    ActiveSupport::HashWithIndifferentAccess.new(decoded)
  end
end
