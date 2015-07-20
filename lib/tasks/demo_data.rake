namespace :bakecycle do
  desc 'Export the first bakery data and save it as demo data source'
  task export_demo_data: :environment do
    bakery = Bakery.first
    exporter = DemoExporter.new(bakery)
    exporter.run
    puts exporter.export.map { |k, v| "#{k}: #{v.count}" }
    puts "Written to #{DemoExporter::DEMO_DATA_YAML}"
  end

  desc 'Reset the first bakery with demodata'
  task import_demo_data: :environment do
    def delete_all(bakery)
      ProductionRun.where(bakery: bakery).delete_all
      Shipment.where(bakery: bakery).delete_all
      Order.where(bakery: bakery).delete_all
      Product.where(bakery: bakery).delete_all
      Recipe.where(bakery: bakery).delete_all
      Ingredient.where(bakery: bakery).delete_all
      Route.where(bakery: bakery).delete_all
      Client.where(bakery: bakery).delete_all
    end
    bakery = Bakery.first
    delete_all(bakery)
    DemoCreator.new(bakery).run
  end
end
