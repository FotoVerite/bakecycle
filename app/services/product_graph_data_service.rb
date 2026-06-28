# frozen_string_literal: true

class ProductGraphDataService
  def self.digest_last_week
    new.digest_last_week
  end

  def digest_last_week
    Bakery.where(id: [1, 17]).find_each do |bakery|
      bakery.products.find_each do |product|
        next if product.shipment_items.empty?
        next if product.graph_data.blank? || product.graph_data["dates"].nil?

        digest_product(product)
      end
    end
  end

  private

  def digest_product(product)
    hash = product.graph_data
    items = product.shipment_items.joins(:shipment).order("shipments.date ASC")

    ((Time.zone.today - 1.week)...Time.zone.today).each do |date|
      date_shipments = items.where("shipments.date" => date)
      index = hash["dates"].index(date.strftime("%Y-%m-%d")) || hash["dates"].count

      hash["dates"][index] = date
      hash["amounts"][index] = date_shipments.sum(&:price)
      hash["shipped"][index] = date_shipments.sum(&:product_quantity)
      hash["shipments_count"][index] = date_shipments.size

      upsert_graph_datum(product, date, hash, index)
    end

    product.update(graph_data: hash)
  end

  def upsert_graph_datum(product, date, hash, index)
    datum = ProductGraphDatum.find_or_initialize_by(product_id: product.id, date: date)
    datum.update!(
      bakery_id: product.bakery_id,
      amount: hash["amounts"][index],
      shipped: hash["shipped"][index],
      shipment_count: hash["shipments_count"][index]
    )
  end
end
