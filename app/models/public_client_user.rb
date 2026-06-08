# frozen_string_literal: true

require "net/http"

class PublicClientUser < ApplicationRecord
  belongs_to :client

  validates :first_name, :last_name, :email, presence: true
  validates :email, confirmation: true

  def name
    "#{first_name} #{last_name}"
  end

  def jwt_token
    payload = {
      exp: Time.now.to_i + 25.years,
      iat: Time.now.to_i,
      iss: ENV["JWT_ISSUER"],
      client_id: client_id
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
      password_confirmation: token
    }
    begin
      uri = URI.join(ENV["PUBLIC_BAKECYCLE"], "api/", "v1/", "members")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"

      request = Net::HTTP::Post.new(uri)
      request["Authorization"] = ENV["JWT_TOKEN"]
      request["Content-Type"] = "application/x-www-form-urlencoded"
      form_data = attributes.each_with_object({}) { |(k, v), h| h["member[#{k}]"] = v.to_s }
      request.set_form_data(form_data)

      http_response = http.request(request)
      response = JSON.parse(http_response.body)

      case http_response
      when Net::HTTPSuccess
        if response["success"] == true
          save
          true
        else
          response["errors"].each do |k, v|
            errors.add(:base, :api, message: "#{k.capitalize}: " + v.join(", "))
          end
          false
        end
      when Net::HTTPUnauthorized
        errors.add(:base, :api, message: "API ISSUE: Unauthorized")
        false
      when Net::HTTPNotFound
        errors.add(:base, :api, message: "API ISSUE: Not Found")
        false
      else
        errors.add(:base, :api, message: "API ISSUE: #{http_response.message}")
        false
      end
    rescue SocketError, Errno::ECONNREFUSED => e
      errors.add(:base, :api, message: "API ISSUE: #{e.message}")
      false
    end
  end
end
