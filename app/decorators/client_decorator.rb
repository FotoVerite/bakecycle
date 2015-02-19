class ClientDecorator < Draper::Decorator
  delegate_all

  def active_status
    active ? "Yes" : "No"
  end

  def charge_delivery_fee_status
    charge_delivery_fee ? "Yes" : "No"
  end

  def billing
    billing_term.humanize(capitalize: false).titleize
  end

  def dba_display
    return "N/A" unless dba.present?
    dba
  end
end
