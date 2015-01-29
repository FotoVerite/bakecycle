class ProductDecorator < Draper::Decorator
  delegate_all

  def type
    product_type.humanize(capitalize: false).titleize
  end

  def truncated_description
    description.truncate(30)
  end
end
