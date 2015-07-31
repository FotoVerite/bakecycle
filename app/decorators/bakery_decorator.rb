class BakeryDecorator < Draper::Decorator
  delegate_all

  def city_state_zip
    "#{object.address_city}, #{object.address_state} #{object.address_zipcode}"
  end

  def logo_errors?
    object.errors[:logo].any? || object.errors[:logo_content_type].any?
  end

  def display_kickoff_time
    return unless kickoff_time
    kickoff_time.strftime("%I:%M%p")
  end

  def display_last_kickoff
    return unless last_kickoff
    last_kickoff.to_s(:long)
  end

  def parameterized_name
    object.name.parameterize
  end

  def plans_select
    Plan.all.map { |plan| [plan.display_name, plan.id] }
  end
end
