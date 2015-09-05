class OrderGenerator
  include GlobalID::Identification

  def self.find(global_id)
    order = Order.find(global_id)
    new(order)
  end

  def initialize(order)
    @order = order
  end

  def id
    @order.id
  end

  def filename
    "Order-#{@order.id}.pdf"
  end

  def generate
    pdf.render
  end

  private

  def pdf
    OrderPdf.new(@order)
  end
end
