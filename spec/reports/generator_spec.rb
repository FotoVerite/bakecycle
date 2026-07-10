# frozen_string_literal: true

require "rails_helper"

describe Generator::CompositeId do
  # A throwaway class exercising every coercer, isolated from any real report's
  # `generate`/`filename` behavior -- this is the one place the composite-ID
  # round-trip itself gets tested, closing the gap where 22+ generator classes
  # each had untested hand-rolled `.find`/`#id` parsing.
  let(:test_class) do
    Class.new do
      include Generator
      composite_id bakery: :bakery, date: :date, type: :string, flag: :bool

      attr_reader :bakery, :date, :type, :flag

      def initialize(bakery, date, type, flag)
        @bakery = bakery
        @date = date.to_date
        @type = type
        @flag = flag
      end

      def filename
        "Test-#{@date.iso8601}.#{@type}"
      end

      def generate
        "generated"
      end
    end
  end

  it "serializes every declared field via its coercer's serializer" do
    bakery = create(:bakery)
    instance = test_class.new(bakery, Date.new(2026, 7, 9), "pdf", true)

    expect(instance.id).to eq("#{bakery.id}_2026-07-09_pdf_true")
  end

  it "round-trips .find(instance.id) back to an equivalent instance" do
    bakery = create(:bakery)
    instance = test_class.new(bakery, Date.new(2026, 7, 9), "xlsx", false)

    found = test_class.find(instance.id)

    expect(found.bakery).to eq(bakery)
    expect(found.date).to eq(Date.new(2026, 7, 9))
    expect(found.type).to eq("xlsx")
    expect(found.flag).to eq(false)
  end

  it "limits the split so only the last declared field can safely contain underscores" do
    bakery = create(:bakery)
    trailing_field_class = Class.new do
      include Generator
      composite_id bakery: :bakery, type: :string

      attr_reader :bakery, :type

      def initialize(bakery, type)
        @bakery = bakery
        @type = type
      end
    end
    instance = trailing_field_class.new(bakery, "weekly_summary")

    found = trailing_field_class.find(instance.id)

    expect(found.type).to eq("weekly_summary")
  end

  # Sample across the real generator classes that declare composite_id, rather
  # than re-testing every one -- this is the contract those 24 classes rely on.
  it "round-trips real generator classes end to end" do
    bakery = create(:bakery)

    bake_list = BakeListGenerator.new(bakery, Date.new(2026, 7, 9))
    expect(BakeListGenerator.find(bake_list.id).generate).to eq(bake_list.generate)

    daily_total = DailyTotalGenerator.new(bakery, Date.new(2026, 7, 9), "xlsx", false)
    found = DailyTotalGenerator.find(daily_total.id)
    expect(found.filename).to eq(daily_total.filename)

    batch = BatchGenerator.new(bakery, Date.new(2026, 7, 9), Date.new(2026, 7, 12))
    expect(BatchGenerator.find(batch.id).filename).to eq(batch.filename)

    vip_list = VipListGenerator.new(bakery)
    expect(VipListGenerator.find(vip_list.id).filename).to eq(vip_list.filename)
  end
end
