require "rails_helper"

FactoryBot.factories.map(&:name).each do |factory_name|
  describe "#{factory_name} factory" do
    it "builds valid" do
      model = FactoryBot.build(factory_name)
      expect(model).to be_valid if model.respond_to?(:valid?)
    end

    it "builds stubbed" do
      model = FactoryBot.build_stubbed(factory_name)
      expect(model).to be_valid if model.respond_to?(:valid?)
    end
  end
end
