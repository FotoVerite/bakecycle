class RouteDecorator < Draper::Decorator
  delegate_all

  def active_status
    active ? 'Yes' : 'No'
  end

  def formatted_time
    departure_time.strftime('%I:%M %p') if departure_time
  end
end
