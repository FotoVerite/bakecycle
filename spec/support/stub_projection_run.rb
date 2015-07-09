def new_stubed_production_run_projection
  today = Time.zone.now
  bakery = build_stubbed(:bakery)
  order_item = new_stubed_order_item(bakery)
  allow(order_item.product.motherdough).to receive(:recipe_items).and_return([])
  projection = ProductionRunProjection.new(bakery, today, today)
  allow(projection).to receive(:order_items).and_return([order_item])
  projection
end

def new_stubed_order_item(bakery)
  order_item = build_stubbed(:order_item, bakery: bakery, force_total_lead_days: 1)
  order_item.product.total_lead_days = 1
  order_item.product.motherdough.total_lead_days = 1
  order_item
end
