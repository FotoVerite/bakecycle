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
        if  hash[i.product_name].nil?
          product_hash = hash[i.product_name] = {}
          product_hash['product_type'] = i.product.attributes['product_type']
          product_hash['name'] = i.product_name
          product_hash['quantity'] = []
        else
          product_hash = hash[i.product_name]
        end
        product_hash['quantity'].push("#{client_name} #{i.product_quantity}")
      end
    end
    hash.sort_by {|k,v| [v['product_type'], v['name']]}
  end

  def add_rows(hash, sheet)
    # Set Product Type Row
    hash.each do |product_array|
      sheet.add_row [product_array[0]], style: @header
      product_array[1]['quantity'].each do |quantities|
        sheet.add_row [quantities]
      end
    end
  end

  def create_output_string(p)
    outstrio = StringIO.new
    p.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(p.to_stream.read)
    outstrio.string
  end
end
