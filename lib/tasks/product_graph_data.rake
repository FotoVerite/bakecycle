# frozen_string_literal: true

namespace :product_graph_data do
  task generate: :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE product_graph_data RESTART IDENTITY")
    Bakery.all.where(id: [1, 17]).find_each do |bakery|
      bakery.products.each do |product|
        hash = { dates: [], amounts: [], shipped: [], shipments_count: [] }
        next if product.shipment_items.empty?

        items = product.shipment_items.joins(:shipment).order("shipments.date ASC")
        (items.first.shipment.date...Time.zone.today).each_with_index do |date, i|
          date_shipments = items.where("shipments.date" => date)
          hash[:dates][i] = date
          hash[:amounts][i] = 0 if hash[:amounts][i].nil?
          hash[:amounts][i] += date_shipments.sum(&:price)
          hash[:shipped][i] = 0 if hash[:shipped][i].nil?
          hash[:shipped][i] += date_shipments.sum(&:product_quantity)
          hash[:shipments_count][i] = 0 if hash[:shipments_count][i].nil?
          hash[:shipments_count][i] = date_shipments.size
          ProductGraphDatum.create(
            bakery_id: bakery.id,
            product_id: product.id,
            date: hash[:dates][i],
            amount: hash[:amounts][i],
            shipped: hash[:shipped][i],
            shipment_count: hash[:shipments_count][i]
          )
        end
        product.graph_data = hash
        product.save
      end
    end
  end

  task digest_last_week: :environment do
    ProductGraphDataService.digest_last_week
  end
end
