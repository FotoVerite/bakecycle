class Week
  attr_reader :end_date, :start_date

  def initialize(end_date)
    @end_date = end_date
    @start_date = end_date - 6
  end
end
