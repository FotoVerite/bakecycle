class OverlappingOrdersValidator < ActiveModel::Validator
  def validate(record)
    return unless record.overlapping?
    ids = record.overlapping_orders.map(&:id).join(',')
    record.errors.add(:start_date, "This order overlaps with ids (#{ids})")
    record.errors.add(:base, 'Change the dates of this order, or create this order by updating overlapping orders.')
  end
end
