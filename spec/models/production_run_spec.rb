require 'rails_helper'

describe ProductionRun do
  describe '.for_date(date)' do
    it 'returns all produciton runs for a date provided' do
      create_list(:production_run, 2, date: Date.today)
      past_production_run = create(:production_run, date: Date.today - 1.day)
      expect(ProductionRun.for_date(Date.today).count).to eq(2)
      expect(ProductionRun.for_date(Date.today).include?(past_production_run)).to eq(false)
    end
  end
end
