class OverlappingOrdersValidator < ActiveModel::Validator
  def validate(record)
    return unless record.overlapping?
    record.errors.add(:start_date, I18n.t('orders.overlapping_start', count: record.overlapping_orders.count))
  end
end
