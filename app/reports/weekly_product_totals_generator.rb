class WeeklyProductTotalsGenerator < ActiveJob::Base
  queue_as :file_exporter

  def self.create(bakery, start_date = Date.today)
    FileExport.create!(bakery: bakery).tap do |file_export|
      perform_later(file_export, "#{bakery.id}_#{start_date.iso8601}")
    end
  end

  def generate(bakery)
    runs = bakery.production_runs.limit(5)
    hash = create_hash_of_products(runs)
    array = create_array_of_rows(hash, Date.today.beginning_of_year - Date.today)
    create_xlsl(array)
  end

  def perform(file_export, global_id)
    return if file_export.file.present?
    bakery_id, start_date_string = global_id.split("_")
    bakery = Bakery.find(bakery_id)
    start_date = Date.iso8601(start_date_string)
    file_export.file = generate(bakery)
    file_export.save!
  rescue Resque::TermException
    Resque.logger.error "Resque job termination re-queuing #{self} #{file_export}, #{generator}"
    self.class.perform_later(file_export, generator)
  end

  private

  def create_hash_of_products(runs)
    hash = {}
    runs.each do |r|
      r.run_items.each do |i|
        product_name = i.product.name
        day_name = r.date.strftime("%A")
        hash[product_name] = {} unless hash[product_name]
        # days
        hash[product_name][day_name] = (i.total_quantity + hash[product_name][day_name].to_i)
        # product price
        hash[product_name]["price"] = i.product.base_price unless hash[product_name]["price"]
        # total products
        hash[product_name]["total_products"] = i.total_quantity + hash[product_name]["total_products"].to_i
      end
    end
    hash
  end

  def create_array_of_rows(hash, days_for_year)
    array = []
    Rails.logger.error(hash)
    hash.each do |key, value|
      array.push([
                   key,
                   value["Monday"] || 0,
                   value["Tuesday"] || 0,
                   value["Wednesday"] || 0,
                   value["Thursday"] || 0,
                   value["Friday"] || 0,
                   value["Saturday"] || 0,
                   value["Sunday"] || 0,
                   value["price"],
                   ((value["total_products"] || 0) / days_for_year).ceil,
                   value["total_products"] || 0,
                   value["price"] * (value["total_products"] / days_for_year).ceil,
                   value["price"] * (value["total_products"] || 0)
                 ])
    end
    array
  end

  def create_xlsl(array)
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(name: "Data Sheet") do |sheet|
      sheet.add_row ["Product Name",
                     "Monday",
                     "Tuesday",
                     "Wednesday",
                     "Thursday",
                     "Friday",
                     "Saturday",
                     "Sunday",
                     "Price",
                     "Avg/Day",
                     "Total/Year",
                     "Daily Value",
                     "Yearly Value"]
      array.each do |row|
        sheet.add_row row
      end
    end
    outstrio = StringIO.new
    p.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(p.to_stream.read)
    FakeFileIO.new("Weekly_Production_Report.xlsx", outstrio.string)
  end
end
