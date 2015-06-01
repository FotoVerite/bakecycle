def stub_production_run_projection(bakery)
  today = Time.zone.now
  order_item = build_stubbed(:order_item, bakery: bakery)
  allow_any_instance_of(ProductionRunProjection).to receive(:order_items).and_return([order_item])
  allow_any_instance_of(Product).to receive(:total_lead_days).and_return(1)
  allow_any_instance_of(Recipe).to receive(:total_lead_days).and_return(1)
  ProductionRunProjection.new(bakery, today, today)
end
