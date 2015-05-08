require 'rails_helper'

describe Order do
  let(:bakery) { build(:bakery) }
  let(:client) { create(:client, bakery: bakery) }
  let(:order) { build(:order, bakery: bakery) }
  let(:today) { Time.zone.today }
  let(:yesterday) { today - 1.day }
  let(:tomorrow) { today + 1.day }
  let(:next_week) { today + 1.week }

  it 'has a shape' do
    expect(order).to respond_to(:client)
    expect(order).to respond_to(:route)
    expect(order).to respond_to(:start_date)
    expect(order).to respond_to(:end_date)
    expect(order).to respond_to(:note)
    expect(order).to respond_to(:order_items)
    expect(order).to respond_to(:order_type)
    expect(order).to belong_to(:bakery)
    expect(order).to belong_to(:client)
    expect(order).to belong_to(:route)

    expect(order).to belong_to(:bakery)
    expect(order).to belong_to(:client)
    expect(order).to belong_to(:route)
    expect(order).to have_many(:order_items)
    expect(order).to have_many(:products)
  end

  it 'has validations' do
    expect(order).to validate_presence_of(:client)
    expect(order).to validate_presence_of(:route)
    expect(order).to validate_presence_of(:start_date)
    expect(order).to validate_presence_of(:order_type)
  end

  context 'date validations' do
    it 'is invalid if the end date is before the start date' do
      order.start_date = today
      order.end_date = yesterday
      expect(order).to_not be_valid
      expect(order.errors[:end_date].count).to be > 0
    end

    describe '#standing_order_date_can_not_overlap' do
      it 'is invalid if two orders overlap' do
        order = create(:order, start_date: today)
        overlaping_order = build(
          :order,
          bakery: order.bakery,
          route: order.route,
          client: order.client,
          start_date: today
        )
        expect(overlaping_order).to_not be_valid
        expect(overlaping_order.errors[:start_date].count).to be > 0
      end
    end

    describe '#set_end_date' do
      it 'has a starting_date that ends on the same day' do
        temp_order = build(:temporary_order)
        temp_order.valid?
        expect(temp_order.start_date).to eq(temp_order.end_date)
      end
    end
  end

  describe '#total_lead_days' do
    it 'returns lead time for order items' do
      motherdough = create(:recipe_motherdough, bakery: bakery, lead_days: 5)
      inclusion = create(:recipe_inclusion, bakery: bakery, lead_days: 3)
      product_1 = create(:product, bakery: bakery, inclusion: inclusion)
      product_2 = create(:product, bakery: bakery, motherdough: motherdough)

      order.order_items << build(:order_item, product: product_1)
      order.order_items << build(:order_item, product: product_2)
      order.save
      expect(order.total_lead_days).to eq(5)
    end
  end

  describe '#overlapping?' do
    it 'returns true if there is an existing overlapping order for the same client and route' do
      route = create(:route, bakery: bakery)
      order = create(:order, bakery: bakery, start_date: today, end_date: tomorrow, route: route, client: client)
      combinations = [
        { start_date: yesterday, end_date: yesterday, result: false },
        { start_date: yesterday, end_date: today, result: true },
        { start_date: yesterday, end_date: tomorrow, result: true },
        { start_date: yesterday, end_date: next_week, result: true },
        { start_date: yesterday, end_date: nil, result: true },
        { start_date: next_week, end_date: nil, result: false },
        { start_date: next_week, end_date: next_week, result: false },
        { start_date: today, end_date: today, result: true },
        { start_date: today, end_date: tomorrow, result: true },
        { start_date: today, end_date: next_week, result: true },
        { start_date: today, end_date: nil, result: true },
        { start_date: tomorrow, end_date: tomorrow, result: true },
        { start_date: tomorrow, end_date: next_week, result: true },
        { start_date: tomorrow, end_date: nil, result: true }
      ]

      combinations.each do |combo|
        start_date, end_date, result = combo.values_at(:start_date, :end_date, :result)
        order = build_stubbed(
          :order,
          bakery: order.bakery,
          route: route, client: client,
          start_date: start_date,
          end_date: end_date
        )
        msg = "expected start_date of #{start_date}, & end_date of #{end_date || 'nil'} to have overlapping? #{result}"
        expect(order.overlapping?).to eq(result), msg
      end
    end

    it 'returns true if there is an existing overlapping order for the same client and route with no end date' do
      client = create(:client)
      route = create(:route)
      order = create(:order, start_date: today, end_date: nil, route: route, client: client)

      combinations = [
        { start_date: yesterday, end_date: yesterday, result: false },
        { start_date: yesterday, end_date: today, result: true },
        { start_date: yesterday, end_date: tomorrow, result: true },
        { start_date: yesterday, end_date: nil, result: true },
        { start_date: today, end_date: today, result: true },
        { start_date: today, end_date: tomorrow, result: true },
        { start_date: today, end_date: nil, result: true },
        { start_date: tomorrow, end_date: tomorrow, result: true },
        { start_date: tomorrow, end_date: nil, result: true }
      ]

      combinations.each do |combo|
        start_date, end_date, result = combo.values_at(:start_date, :end_date, :result)
        order = build_stubbed(
          :order,
          bakery: order.bakery,
          route: route,
          client: client,
          start_date: start_date,
          end_date: end_date
        )
        msg = "expected start_date of #{start_date}, & end_date of #{end_date || 'nil'} to have overlapping? #{result}"
        expect(order.overlapping?).to eq(result), msg
      end
    end

    it 'returns false if there are overlapping orders for other clients and temporary orders' do
      order = build(:order, start_date: today, end_date: today)
      create(:temporary_order, route: order.route, client: order.client, start_date: today)
      create(:order, route: order.route, start_date: today)
      create(:order, client: order.client, start_date: today)
      expect(order).to_not be_overlapping
    end

    it 'lets temporary orders get away with not having an end date' do
      order = create(:temporary_order, start_date: today)
      not_overlapping = create(:temporary_order, start_date: tomorrow, client: order.client, route: order.route)
      expect(not_overlapping).to_not be_overlapping
      expect(order).to_not be_overlapping
    end

    it 'returns false if it overlaps with itself' do
      order = create(:order, start_date: today, end_date: today)
      expect(order).to_not be_overlapping
    end
  end

  describe '.temporary' do
    it 'returns all temporary orders on a date' do
      temp_order = create(:temporary_order, start_date: today)
      create(:temporary_order, start_date: today + 1.day)
      create(:order)

      expect(Order.temporary(today)).to contain_exactly(temp_order)
    end
  end

  describe '.standing' do
    it 'returns all standing orders active on a day' do
      order = create(:order, start_date: today, end_date: today)
      order2 = create(:order, start_date: yesterday, end_date: today + 1.day)
      order3 = create(:order, start_date: yesterday, end_date: nil)
      create(:order, start_date: yesterday, end_date: yesterday)
      create(:temporary_order, start_date: today)

      expect(Order.standing(today)).to contain_exactly(order, order2, order3)
    end
  end

  describe '.active' do
    it 'returns all active orders for a date' do
      order = create(:order, start_date: yesterday)
      client = order.client
      temp_order = create(:temporary_order, start_date: today, client: client, route: order.route)
      different_route = create(:order, start_date: yesterday, client: client)
      expect(Order.active(yesterday)).to contain_exactly(order, different_route)
      expect(Order.active(today)).to contain_exactly(temp_order, different_route)
    end

    it 'allows scoping to clients' do
      create(:order, start_date: yesterday)
      order = create(:order, start_date: yesterday)
      client = order.client
      expect(client.orders.active(today)).to contain_exactly(order)
    end
  end

  describe '.upcoming' do
    it 'shows all orders that are not past their end date' do
      route = create(:route, bakery: bakery)
      route_2 = create(:route, bakery: bakery)
      combinations = [
        { start_date: yesterday, end_date: yesterday, route: route, order_type: 'temporary' },
        { start_date: today, end_date: today, route: route, order_type: 'temporary' },
        { start_date: yesterday, end_date: nil, route: route, order_type: 'standing' },
        { start_date: yesterday, end_date: nil, route: route_2, order_type: 'standing' },
        { start_date: tomorrow, end_date: tomorrow, route: route, order_type: 'temporary' }
      ]

      combinations.each do |combo|
        start_date, end_date, route, order_type = combo.values_at(:start_date, :end_date, :route, :order_type)
        create(
          :order,
          bakery: bakery,
          route: route,
          client: client,
          start_date: start_date,
          end_date: end_date,
          order_type: order_type
        )
      end

      expired_order = Order.find_by(end_date: yesterday)

      expect(Order.upcoming(today).count).to eq(4)
      expect(Order.upcoming(today)).not_to include(expired_order)
    end
  end
end
