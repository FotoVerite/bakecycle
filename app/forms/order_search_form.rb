class OrderSearchForm
  attr_accessor :client_id, :route_id, :date, :product_id

  def initialize(params)
    return unless params
    @client_id = params[:client_id]
    @route_id = params[:route_id]
    @date = parse_date(params[:date])
    @product_id = params[:product_id]
  end

  def parse_date(date)
    date = Chronic.parse(date)
    date.to_date if date
  end

  def to_h
    {
      client_id: client_id,
      route_id: route_id,
      date: date,
      product_id: product_id
    }
  end

  delegate :[], to: :to_h
end
