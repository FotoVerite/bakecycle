class PublicClientUserPolicy < UserPolicy
  def permitted_attributes
    attributes = %i[first_name last_name client_id email email_confirmation]
    attributes
  end
end
