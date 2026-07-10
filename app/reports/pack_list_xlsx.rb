# frozen_string_literal: true

class PackListXlsx
  include XlsxReport

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
    @header = styles.add_style sz: 16, b: true, alignment: { horizontal: :center }
    wb.add_worksheet(name: "Data Sheet") do |sheet|
      sheet.add_row headers
      add_rows(hash, sheet)
    end
    create_output_string(p)
  end

  def create_hash_of_products
    hash = {}
    @shipments.each do |shipment|
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
      sheet.add_row ["Total: #{product_array[1]['total']}"]
    end
  end

end
