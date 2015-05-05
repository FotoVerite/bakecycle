class OrderSearchForm
  attr_accessor :client_id, :route_id, :date

  def initialize(params)
    return unless params
    @client_id = params[:client_id]
    @route_id = params[:route_id]
    @date = parse_date(params[:date])
  end

  def parse_date(date)
    date = Chronic.parse(date)
    date.to_date if date
  end

  def to_h
    {
      client_id: client_id,
      route_id: route_id,
      date: date
    }
  end

  delegate :[], to: :to_h
end
