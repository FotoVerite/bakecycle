# == Schema Information
#
# Table name: ingredients
#
#  id              :integer          not null, primary key
#  name            :string
#  description     :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  bakery_id       :integer          not null
#  legacy_id       :string
#  ingredient_type :string           default("other"), not null
#

require "rails_helper"

describe Ingredient do
  let(:ingredient) { build(:ingredient) }

  it "has a shape" do
    expect(ingredient).to respond_to(:name)
    expect(ingredient).to respond_to(:description)
    expect(ingredient).to belong_to(:bakery)
  end

  it "has validations" do
    expect(ingredient).to validate_presence_of(:name)
    expect(ingredient).to validate_length_of(:name).is_at_most(150)
    expect(ingredient).to validate_length_of(:description).is_at_most(500)
  end

  it "validates uniqueness of name" do
    expect(ingredient).to validate_uniqueness_of(:name).scoped_to(:bakery_id)
  end

  describe "#destroy" do
    it "wont destroy if it's used in a recipe" do
      bakery = create(:bakery)
      inclusion = create(:ingredient, bakery: bakery)
      recipe = create(:recipe, bakery: bakery)
      create(:recipe_item, recipe: recipe, inclusionable: inclusion)
      expect(inclusion.destroy).to eq(false)
      expect(inclusion.errors.to_a).to eq(["This ingredient is still used in a recipe"])
    end
  end
end
