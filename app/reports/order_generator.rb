# frozen_string_literal: true

class OrderGenerator
  include Generator

  def self.find(global_id)
    order = Order.find(global_id)
    new(order)
  end

  def initialize(order)
    @order = order
  end

  delegate :id, to: :@order

  def filename
    Generator.client_filename(@order.client.name, "Order-#{@order.id}.pdf")
  end

  def generate
    pdf.render
  end

  private

  def pdf
    OrderPdf.new(@order)
  end
end
