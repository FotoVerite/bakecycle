require "rails_helper"

describe OrderItem do
  let(:bakery) { create(:bakery) }
  let(:order_item) { build(:order_item) }
  let(:tomorrow) { Time.zone.tomorrow }
  let(:yesterday) { Time.zone.yesterday }
  let(:today) { Time.zone.today }
  let(:last_week) { today - 7.days }
  let(:two_days_ago) { today - 2.days }

  it "has a shape" do
    expect(order_item).to respond_to(:product)
    expect(order_item).to respond_to(:monday)
    expect(order_item).to respond_to(:tuesday)
    expect(order_item).to respond_to(:wednesday)
    expect(order_item).to respond_to(:thursday)
    expect(order_item).to respond_to(:friday)
    expect(order_item).to respond_to(:saturday)
    expect(order_item).to respond_to(:sunday)
    expect(order_item).to belong_to(:product)
  end

  it "has days of week default to 0" do
    order_item = build(:order_item, monday: nil)
    expect(order_item.monday).to eq(nil)
    order_item.save
    expect(order_item.monday).to eq(0)
  end

  it "has validations" do
    expect(order_item).to validate_numericality_of(:monday)
    expect(order_item).to validate_numericality_of(:tuesday)
    expect(order_item).to validate_numericality_of(:wednesday)
    expect(order_item).to validate_numericality_of(:thursday)
    expect(order_item).to validate_numericality_of(:friday)
    expect(order_item).to validate_numericality_of(:saturday)
    expect(order_item).to validate_numericality_of(:sunday)
  end

  describe "#total_quantity" do
    it "sums up the quantity of each day" do
      order_item = build(
        :order_item,
        monday: 1,
        tuesday: 2,
        wednesday: 10,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: nil
      )
      expect(order_item.total_quantity).to eq(13)
    end
  end

  describe "#quantity" do
    it "returns the quantity ordered on a date" do
      order_item = OrderItem.new(monday: 4)
      monday = Date.parse("16/02/2015")
      expect(order_item.quantity(monday)).to eq(order_item.monday)
    end
  end

  describe ".total_quantity_price" do
    let(:order) { create(:order, start_date: today, order_item_count: 1, product_total_lead_days: 2) }

    it "calculates total quantity price for an order item" do
      apple = create(:product, name: "Apple", base_price: 0.5)
      create(:price_variant, product: apple, quantity: 11, price: 0.4, client: order.client)
      create(:price_variant, product: apple, quantity: 13, price: 0.2, client: order.client)
      create(:price_variant, product: apple, quantity: 15, price: 0.1, client: order.client)

      order_item = create(
        :order_item,
        order: order,
        product: apple,
        monday: 1,
        tuesday: 1,
        wednesday: 1,
        thursday: 1,
        friday: 1,
        saturday: 1,
        sunday: 1
      )

      expect(order_item.total_quantity_price).to eq(3.5)

      order_item.monday = 4
      expect(order_item.total_quantity_price).to eq(5)

      order_item.monday = 11
      expect(order_item.total_quantity_price).to eq(1.7)
    end
  end

  context "start dates" do
    let(:order) { create(:order, start_date: today, order_item_count: 1, product_total_lead_days: 2) }
    let(:order_item) { order.order_items.first }
    let(:lead_time) { order_item.total_lead_days }

    describe "#production_start_on?(date)" do
      it "returns true if production can start on the date given based on lead time and day of week" do
        sunday = Time.zone.now.sunday
        expect(order_item.production_start_on?(sunday)).to eq(true)
      end

      it "returns false if production cannot start on the date given based on lead time and day of week" do
        order_item.update(wednesday: 0)
        monday = Time.zone.now.monday
        expect(order_item.production_start_on?(monday)).to eq(false)
      end
    end

    describe ".production_date(date)" do
      it "returns only order_items that have a quantity for a given date" do
        expect(OrderItem.production_date(today)).to contain_exactly(order_item)
        expect(OrderItem.production_date(two_days_ago)).to contain_exactly(order_item)
        expect(OrderItem.production_date(last_week)).to_not contain_exactly(order_item)
      end

      it "only returns items from active orders" do
        order.update!(start_date: last_week)
        temp_order = create(
          :temporary_order,
          bakery: order.bakery,
          client: order.client,
          route: order.route,
          start_date: tomorrow,
          order_item_count: 1,
          product_total_lead_days: 2
        )
        temp_order_item = temp_order.order_items.first
        expect(OrderItem.production_date(two_days_ago)).to contain_exactly(order_item)
        expect(OrderItem.production_date(yesterday)).to contain_exactly(temp_order_item)
      end

      it "only returns items from active orders when there are expired orders" do
        order.update!(start_date: last_week)
        create(
          :temporary_order,
          bakery: order.bakery,
          client: order.client,
          route: order.route,
          start_date: last_week,
          end_date: last_week,
          order_item_count: 1,
          product_total_lead_days: 2
        )
        expect(OrderItem.production_date(yesterday)).to contain_exactly(order_item)
      end

      it "returns orders with multiple lead times" do
        order = create(:temporary_order, start_date: tomorrow, order_item_count: 0, bakery: bakery)
        two_day_lead = create(:order_item, force_total_lead_days: 2, order: order, bakery: bakery)
        one_day_lead = create(:order_item, force_total_lead_days: 1, order: order, bakery: bakery)
        expect(OrderItem.production_date(yesterday)).to contain_exactly(two_day_lead)
        expect(OrderItem.production_date(today)).to contain_exactly(one_day_lead)
      end

      it "returns both standing and temp orders with same start date and different lead times" do
        temp = create(
          :temporary_order,
          start_date: tomorrow,
          product_total_lead_days: 1,
          bakery: bakery
        )
        standing = create(
          :order,
          client: temp.client,
          route: temp.route,
          start_date: tomorrow + 1.day,
          product_total_lead_days: 2,
          bakery: bakery
        )
        temp_order_items = temp.order_items.first
        standing_order_items = standing.order_items.first

        expect(OrderItem.production_date(today)).to contain_exactly(temp_order_items, standing_order_items)
      end
    end

    context "after_touch" do
      describe "update_total_lead_days" do
        it "updates its total_lead_days when the product is updated" do
          order_item = create(:order_item, total_lead_days: 3)
          product = order_item.product
          product.update(total_lead_days: 8)
          order_item.reload
          expect(order_item.total_lead_days).to eq(8)
        end
      end
    end
  end
end
