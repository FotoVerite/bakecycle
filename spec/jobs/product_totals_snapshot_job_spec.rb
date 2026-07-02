# frozen_string_literal: true

require "rails_helper"

describe ProductTotalsSnapshotJob do
  it "captures one nightly order-projection snapshot per bakery" do
    bakery_a = create(:bakery)
    bakery_b = create(:bakery)

    expect { described_class.perform_now }.to change(ProductTotalsSnapshot, :count).by(2)

    snapshot = ProductTotalsSnapshot.find_by!(bakery: bakery_a)
    expect(snapshot).to have_attributes(
      source: "order_projection",
      label: ProductTotalsSnapshot::NIGHTLY,
      start_date: Time.zone.today,
      end_date: Time.zone.today + (described_class::WINDOW_DAYS - 1).days
    )
    expect(ProductTotalsSnapshot.where(bakery: bakery_b)).to exist
  end

  it "does not double-capture when rerun on the same day" do
    create(:bakery)

    described_class.perform_now

    expect { described_class.perform_now }.to_not change(ProductTotalsSnapshot, :count)
  end
end
