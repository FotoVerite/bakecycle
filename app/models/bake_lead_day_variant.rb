# frozen_string_literal: true

# == Schema Information
#
# Table name: bake_lead_day_variants
#
#  id              :bigint           not null, primary key
#  product_id      :bigint           not null
#  client_id       :bigint           not null
#  bake_lead_days  :integer          not null
#  removed         :integer          default(0)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

# Per-client override of a product's bake lead time, mirroring PriceVariant
# exactly (app/models/price_variant.rb) -- the same pattern staff already
# know from pricing. Unlike PriceVariant, client_id is required here: the
# product-level default already lives on Product#bake_lead_days, so a
# variant only ever exists to express a client-specific override, not a
# second place to store the default.
class BakeLeadDayVariant < ApplicationRecord
  has_paper_trail

  belongs_to :product
  belongs_to :client

  validates :bake_lead_days, presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :client_id, uniqueness: { scope: :product_id }

  def client_name
    client&.name || ""
  end

  def destroy
    self.removed = true
    save
  end
end
