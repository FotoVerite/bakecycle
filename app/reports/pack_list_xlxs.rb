class PackListXlxs
  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    @shipments = Shipment.where(bakery: bakery, date: date)
  end

  def generate
    hash = create_hash_of_products
    headers = ["Pack List - #{@date}"]
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "000099", sz: 16, b: true, alignment: { horizontal: :center }
    wb.add_worksheet(name: "Data Sheet") do |sheet|
      sheet.add_row headers
      add_rows(hash, sheet)
    end
    create_output_string(p)
  end

  # rubocop:disable Metrics/AbcSize

  def create_hash_of_products
    hash = {}
    @shipments.each do |shipment|
      client_name = shipment.client.name
      shipment.shipment_items.each do |i|
        product_hash = hash[i.product_name].nil? ? hash[i.product_name] = [] : hash[i.product_name]
        product_hash.push("#{client_name} #{i.product_quantity}")
      end
    end
    hash
  end

  def add_rows(hash, sheet)
    array = []
    # Set Product Type Row
    hash.each do |key, product_values|
      sheet.add_row [key], style: @header
      product_values.each do |v|
        sheet.add_row [v]
      end
    end
    array
  end

  def create_output_string(p)
    outstrio = StringIO.new
    p.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(p.to_stream.read)
    outstrio.string
  end
end
