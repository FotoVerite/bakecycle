class ClientDecorator < Draper::Decorator
  delegate_all

  def active_status
    active ? "Yes" : "No"
  end

  def billing
    billing_term.humanize(capitalize: false).titleize
  end
end
