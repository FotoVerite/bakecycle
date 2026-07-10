# frozen_string_literal: true

class ProductPricingXlsx
  include XlsxReport

  def initialize(bakery, date)
    @bakery = bakery
    @date = date
    @products = @bakery.products.available
  end

  def generate
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @header = styles.add_style bg_color: "DD", sz: 16, b: true, alignment: { horizontal: :left }
    wb.add_worksheet(name: "Product Pricing for #{@date}") do |sheet|
      sheet.add_row(["Product Name", "Sku", "Cog", "Base Price"], header: @header)
      add_rows(@products, sheet)
    end
    create_output_string(p)
  end

  def add_rows(products, sheet)
    # Set Product Type Row
    products.each do |p|
      sheet.add_row [p.name, p.sku, p.cog, p.base_price]
    end
  end

end
