class IngredientsPricingXlsx
  def initialize(bakery)
    @bakery = bakery
    @vendors = bakery.vendors.order("Name ASC")
  end

  def generate
    headers = ["Ingredient"] + @vendors.map(&:name)
    p = Axlsx::Package.new
    wb = p.workbook
    styles = wb.styles
    @bold = styles.add_style sz: 12, b: true
    wb.add_worksheet(name: "Ingredients Pricing #{Time.zone.today}") do |sheet|
      sheet.add_row headers
      @bakery.ingredients.each do |i|
        row = []
        row.push(i.name)
        vendor_array = []
        @vendors.each do |v|
          vendor_array.push(IngredientPricesOverTime
            .order("created_at DESC").find_by(ingredient_id: i.id, vendor_id: v.id))
        end
        next if vendor_array.compact.empty?
        lowest_cost_array = vendor_array.compact.sort_by(&:cost_per_unit)
        lowest_cost_id = lowest_cost_array.first.id
        vendor_array.each do |price|
          price.lowest_cost = true if price.try(:id) == lowest_cost_id
        end
        row += vendor_array.map(&:cost_per_unit)

        sheet.add_row row, style: [nil] + vendor_array.map { |price| price.try(:lowest_cost) ? @bold : nil }
      end
    end
    create_output_string(p)
  end

  def create_output_string(page)
    outstrio = StringIO.new
    page.use_shared_strings = true # Otherwise strings don't display in iWork Numbers
    outstrio.write(page.to_stream.read)
    outstrio.string
  end
end
