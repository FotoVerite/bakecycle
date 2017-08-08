class TestProjectionGenerator
  include GlobalID::Identification

  def self.find(global_id)
    global_id_array = global_id.split("_")
    bakery = Bakery.find(global_id_array.shift)
    new(bakery, Time.zone.today, global_id_array)
  end

  def initialize(bakery, start_date, order_item_array)
    @bakery = bakery
    @start_date = start_date.to_date
    @order_item_array = order_item_array
    @order_items = order_item_array.map do |o|
      parameters = o.split(":")
      product = Product.find(parameters[0])
      OrderItem.new(
        product_id: parameters[0],
        (@start_date + product.total_lead_days)
        .strftime("%A").downcase => parameters[1]
      )
    end
  end

  def id
    "#{@bakery.id}_#{@order_item_array.join('_')}"
  end

  def filename
    "Production_Run_Projection_#{@start_date}.pdf"
  end

  def generate
    pdf.render
  end

  private

  def pdf
    projection = ProductionRunProjection.new(@bakery, @start_date)
    projection.order_items = @order_items
    projection_data = ProjectionRunData.new(projection)
    ProductionRunPdf.new(projection_data)
  end
end
