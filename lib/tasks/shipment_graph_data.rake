namespace :shipment_graph_data do
  task generate: :environment do
    ActiveRecord::Base.connection.execute("TRUNCATE shipment_graph_data RESTART IDENTITY")
    Bakery.all.each do |bakery|
      hash = { dates: [], amounts: [], product_counts: [] }
      shipments = bakery.shipments.order("date ASC")
      next if shipments.empty?
      (shipments.first.date...Time.zone.today).each_with_index do |date, i|
        date_shipments = shipments.where(date: date)
        hash[:dates][i] = date
        hash[:amounts][i] = 0 if hash[:amounts][i].nil?
        hash[:amounts][i] += date_shipments.sum(&:price)
        hash[:product_counts][i] = 0 if hash[:product_counts][i].nil?
        hash[:product_counts][i] += date_shipments.sum(&:total_quantity)
        ShipmentGraphDatum.create(
          bakery_id: bakery.id,
          date: hash[:dates][i],
          amount: hash[:amounts][i],
          product_count: hash[:product_counts][i]
        )
      end
      bakery.update_attributes(graph_data: hash)
    end
  end

  task digest_last_week: :environment do
    Bakery.all.each do |bakery|
      shipments = bakery.shipments.order("date ASC")
      next if shipments.empty?
      next if bakery.graph_data.nil?
      hash = bakery.graph_data
      ((Time.zone.today - 1.week)...Time.zone.today).each do |date|
        next if bakery.graph_data["dates"].nil?
        date_shipments = shipments.where(date: date)
        i = hash["dates"].index date.strftime("%Y-%m-%d")
        i ||= hash["dates"].count
        hash["amounts"][i] = 0
        hash["product_counts"][i] = 0
        hash["dates"][i] = date
        hash["amounts"][i] += date_shipments.sum(&:price)
        hash["product_counts"][i] += date_shipments.sum(&:total_quantity)
        datum = ShipmentGraphDatum.where(bakery_id: bakery.id, date: date).first
        if datum
          datum.update_attributes(
            amount: hash["amounts"][i],
            product_count: hash["product_counts"][i]
          )
        else
          ShipmentGraphDatum.create(
            bakery_id: bakery.id,
            date: hash["dates"][i],
            amount: hash["amounts"][i],
            product_count: hash["product_counts"][i]
          )
        end
      end
      bakery.update_attributes(graph_data: hash)
    end
  end
end
