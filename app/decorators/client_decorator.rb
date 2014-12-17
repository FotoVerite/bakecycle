class ClientDecorator < Draper::Decorator
  delegate_all

  def active_status
    active ? "Yes" : "No"
  end
end
