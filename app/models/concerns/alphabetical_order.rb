# frozen_string_literal: true

module AlphabeticalOrder
  def order_by_name
    order("lower(name) ASC")
  end
end
