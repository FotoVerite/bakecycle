# frozen_string_literal: true

require "rails_helper"

describe PruneProductTotalsSnapshotsJob do
  let(:bakery) { create(:bakery) }

  def build_snapshot(label:, created_at:)
    snapshot = ProductTotalsSnapshot.create!(
      bakery: bakery,
      source: "order_projection",
      label: label,
      start_date: created_at.to_date,
      end_date: created_at.to_date,
      created_at: created_at
    )
    ProductTotalsSnapshotRow.create!(
      snapshot: snapshot,
      delivery_date: created_at.to_date,
      product_id: 1,
      product_name: "Croissant",
      quantity: 10
    )
    snapshot
  end

  it "prunes expired nightly snapshots and their rows, keeping everything else" do
    expired_nightly = build_snapshot(label: "nightly", created_at: 91.days.ago)
    fresh_nightly = build_snapshot(label: "nightly", created_at: 2.days.ago)
    expired_other_label = build_snapshot(label: "manual", created_at: 91.days.ago)

    described_class.perform_now

    expect(ProductTotalsSnapshot.where(id: expired_nightly.id)).to_not exist
    expect(ProductTotalsSnapshotRow.where(snapshot_id: expired_nightly.id)).to_not exist
    expect(ProductTotalsSnapshot.where(id: fresh_nightly.id)).to exist
    expect(fresh_nightly.rows.count).to eq(1)
    expect(ProductTotalsSnapshot.where(id: expired_other_label.id)).to exist
  end
end
