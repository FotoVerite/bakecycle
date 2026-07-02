# frozen_string_literal: true

class ProductTotalsSnapshotRow < ApplicationRecord
  belongs_to :snapshot, class_name: "ProductTotalsSnapshot", inverse_of: :rows

  # No belongs_to :product -- product_id is a plain integer with no FK, so a
  # row still identifies its product (via denormalized product_name) after
  # the product is deleted.
end
