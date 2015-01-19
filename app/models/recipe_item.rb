class RecipeItem < ActiveRecord::Base
  belongs_to :inclusionable, polymorphic: true

  validates :inclusionable, :bakers_percentage, presence: true
  validates :bakers_percentage, format: { with: /\A\d+(?:\.\d{0,3})?\z/ }, numericality: { greater_than: 0.001 }

  def self.inclusionable_items
    items = []
    [Ingredient, Recipe].each do |klass|
      klass.all.each do |p|
        items << [p.name, "#{p.id}-#{p.class}"]
      end
    end
    items
  end

  def inclusionable_id_type=(composit_id)
    self.inclusionable_id, self.inclusionable_type = composit_id.split('-')
  end

  def inclusionable_id_type
    "#{inclusionable_id}-#{inclusionable_type}"
  end
end
