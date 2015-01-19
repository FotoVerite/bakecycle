require 'rails_helper'

FactoryGirl.factories.map(&:name).each do |factory_name|
  describe "factory #{factory_name}" do
    it 'is valid' do
      model = FactoryGirl.build(factory_name)
      expect(model).to be_valid if model.respond_to?(:valid?)
    end
  end
end
