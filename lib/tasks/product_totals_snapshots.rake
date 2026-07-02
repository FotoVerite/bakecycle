# frozen_string_literal: true

namespace :product_totals_snapshots do
  desc "DEV ONLY: fabricate backdated nightly snapshots (default 30 days) by fuzzing the current order projection"
  task :backfill_dev, [:days] => :environment do |_t, args|
    abort "Refusing to fabricate snapshot data outside development" unless Rails.env.development?

    days = (args[:days] || 30).to_i
    window = ProductTotalsSnapshotJob::WINDOW_DAYS

    Bakery.find_each do |bakery|
      base = ProductTotalsQuery.new(
        bakery, Time.zone.today, Time.zone.today + 6.days,
        source: ProductTotalsQuery::DEFAULT_SOURCE
      ).totals
      if base.empty?
        puts "#{bakery.name}: no current order projection, skipping"
        next
      end

      # Orders repeat weekly, so today's projection keyed by weekday is a
      # realistic template for any past date.
      weekday_quantities = Hash.new { |hash, key| hash[key] = {} }
      product_names = {}
      base.each do |date, product, quantity|
        weekday_quantities[date.wday][product.id] = quantity
        product_names[product.id] = product.name
      end

      created = 0
      days.downto(1) do |age|
        captured_on = Time.zone.today - age.days
        next if ProductTotalsSnapshot
          .where(bakery: bakery, label: ProductTotalsSnapshot::NIGHTLY)
          .where(created_at: captured_on.all_day)
          .exists?

        captured_at = captured_on.in_time_zone.change(hour: 6, min: 15)
        snapshot = ProductTotalsSnapshot.create!(
          bakery: bakery,
          source: ProductTotalsQuery::DEFAULT_SOURCE,
          label: ProductTotalsSnapshot::NIGHTLY,
          start_date: captured_on,
          end_date: captured_on + (window - 1).days,
          created_at: captured_at,
          updated_at: captured_at
        )

        # Deterministic per snapshot so reruns produce the same shape.
        rng = Random.new((bakery.id * 10_000) + age)
        rows = []
        (snapshot.start_date..snapshot.end_date).each do |delivery_date|
          weekday_quantities[delivery_date.wday].each do |product_id, quantity|
            next if rng.rand < 0.05 # product occasionally missing from the plan

            drift = 1.0 + (0.18 * Math.sin((delivery_date.yday + product_id) / 3.2)) + ((rng.rand - 0.5) * 0.2)
            drift *= 1.5 if rng.rand < 0.03 # occasional order spike
            fuzzed = (quantity * drift).round
            next unless fuzzed.positive?

            rows << {
              snapshot_id: snapshot.id,
              delivery_date: delivery_date,
              product_id: product_id,
              product_name: product_names[product_id],
              quantity: fuzzed
            }
          end
        end
        ProductTotalsSnapshotRow.insert_all(rows) if rows.any?
        created += 1
      end
      puts "#{bakery.name}: fabricated #{created} snapshots"
    end
  end
end
