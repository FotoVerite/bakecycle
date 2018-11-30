class SortedPackListXlsx
  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    @grouped_shipments = Shipment.where(bakery: bakery, date: date).order("route_name ASC, client_name ASC").group_by(&:route_name)
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style sz: 15, b: true, alignment: { horizontal: :left }
    @rows = styles.add_style sz: 14, b: false, alignment: { horizontal: :left }
    @grouped_shipments.each do |shipments|
      wb.add_worksheet(name: "#{@date} #{shipments[0]}".truncate(30, omission: "")) do |sheet|
        hash = create_hash_of_products(shipments[1])
        sheet.add_row ["Pack List - #{@date} #{shipments[0]}"]
        sheet.add_row []
        add_rows(hash, sheet)
      end
    end
    create_output_string(p)
  end

  def create_hash_of_products(shipments)
    hash = {}
    shipments.each do |shipment|
      client_name = shipment.client.name
      shipment.shipment_items.each do |i|
        if hash[i.product_name].nil?
          product_hash = hash[i.product_name] = {}
          product_hash["product_type"] = i.product.attributes["product_type"]
          product_hash["name"] = i.product_name
          product_hash["quantity"] = {}
          product_hash["total"] = 0
        else
          product_hash = hash[i.product_name]
        end
        product_hash["quantity"][client_name.to_s] = 0 if product_hash["quantity"][client_name.to_s].nil?
        product_hash["quantity"][client_name.to_s] += i.product_quantity
        product_hash["total"] = (product_hash["total"].to_i + i.product_quantity)
      end
    end
    hash.sort_by { |_k, v| [v["product_type"], v["name"]] }
  end

  # rubocop:enable

  def add_rows(hash, sheet)
    # Set Product Type Row
    hash.each do |product_array|
      sheet.add_row [product_array[0]], style: @header
      product_array[1]["quantity"].each do |client_name, quantity|
        sheet.add_row ["#{client_name} #{quantity}"]
      end
      sheet.add_row ["Total: " + product_array[1]["total"].to_s]
      sheet.add_row []
    end
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
