require "rails_helper"

describe ApplicationHelper, type: :helper do
  describe "#class_for_main_content" do
    it "returns the navigation layout classes when nav renders" do
      helper.instance_variable_set(:@_render_nav, true)

      expect(helper.class_for_main_content).to eq(
        "large-10 medium-12 small-12 columns light-grey-bg-pattern"
      )
    end

    it "returns the centered layout classes when nav does not render" do
      helper.instance_variable_set(:@_render_nav, false)

      expect(helper.class_for_main_content).to eq(
        "medium-6 medium-offset-3 small-10 small-offset-1 columns light-grey-bg-pattern"
      )
    end
  end

  describe "#active_nav?" do
    it "returns active nav classes when the active section is included" do
      helper.instance_variable_set(:@_active_nav, :orders)

      expect(helper.active_nav?(:clients, :orders, :shipments)).to eq("active show-nav")
    end

    it "returns nil when the active section is not included" do
      helper.instance_variable_set(:@_active_nav, :products)

      expect(helper.active_nav?(:clients, :orders, :shipments)).to be_nil
    end
  end

  describe "#full_title" do
    it "returns the base title when no page title is given" do
      expect(helper.full_title).to eq("Bakecycle")
    end

    it "returns the base title when the page title is blank" do
      expect(helper.full_title("")).to eq("Bakecycle")
    end

    it "prefixes the page title" do
      expect(helper.full_title("Orders")).to eq("Orders - Bakecycle")
    end
  end

end
