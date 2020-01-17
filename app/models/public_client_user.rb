class PublicClientUser < ApplicationRecord
  belongs_to :client

  validates :first_name, :last_name, :email, presence: true
  validates :email, confirmation: true

  OpenSSL::SSL::SSLContext::DEFAULT_PARAMS[:ciphers]=OpenSSL::SSL::SSLContext.new.ciphers;


  def name
    "#{first_name} #{last_name}"
  end

  def jwt_token
    payload = {
      exp: Time.now.to_i + 25.years,
      iat: Time.now.to_i,
      iss: ENV["JWT_ISSUER"],
      client_id: client_id,
    }
    JWT.encode payload, ENV["JWT_SECRET"], "HS256"
  end

  def publish_user
    token = SecureRandom.hex(10)
    attributes = {
      client_name: client.name,
      email: email,
      first_name: first_name,
      jwt_token: jwt_token,
      last_name: last_name,
      password: token,
      password_confirmation: token,
    }
    begin
      response = JSON.parse(
        RestClient.post(
          URI.join(ENV["PUBLIC_BAKECYCLE"], "api/", "v1/", "members").to_s,
          { member: attributes },
          headers = { AUTHORIZATION: ENV["JWT_TOKEN"] }
        )
      )
      if response["success"] === true
        self.save
        return true
      else
        response["errors"].each do |k, v|
          self.errors.add(:base, :api, message: "#{k.capitalize}: " + v.join(", "))
        end
        return false
      end
    rescue RestClient::Unauthorized => e
      self.errors.add(:base, :api, message: "API ISSUE: " + e.message)
      return false
    rescue RestClient::ResourceNotFound => e
      self.errors.add(:base, :api, message: "API ISSUE: " + e.message)
      return false
    rescue SocketError => e
      self.errors.add(:base, :api, message: "API ISSUE: " + e.message)
      return false
    rescue Errno::ECONNREFUSED => e
      self.errors.add(:base, :api, message: "API ISSUE: " + e.message)
      return false
    end
  end
end
