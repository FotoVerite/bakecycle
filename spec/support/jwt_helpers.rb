# frozen_string_literal: true

module JwtHelpers
  JWT_TEST_SECRET = "test_secret"
  JWT_TEST_ISSUER = "test_issuer"

  def jwt_auth_header(client_id)
    payload = { client_id: client_id, iss: JWT_TEST_ISSUER, iat: Time.now.to_i }
    token = JWT.encode(payload, JWT_TEST_SECRET, "HS256")
    { "Authorization" => token }
  end
end

RSpec.configure do |config|
  config.include JwtHelpers, type: :request
end
