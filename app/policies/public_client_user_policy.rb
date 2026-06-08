# frozen_string_literal: true

class PublicClientUserPolicy < UserPolicy
  def permitted_attributes
    %i[first_name last_name client_id email email_confirmation]
  end
end
