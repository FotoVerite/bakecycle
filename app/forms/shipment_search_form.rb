class ShipmentSearchForm
  attr_accessor :client_id, :date_from, :date_to, :product_id

  def initialize(params)
    return unless params
    @client_id = params[:client_id]
    @date_from = parse_date(params[:date_from])
    @date_to = parse_date(params[:date_to])
    @product_id = params[:product_id]
  end

  def parse_date(date)
    date = Chronic.parse(date)
    date.to_date if date
  end

  def to_h
    {
      client_id: client_id,
      date_from: date_from,
      date_to: date_to,
      product_id: product_id
    }
  end

  delegate :[], to: :to_h
end
