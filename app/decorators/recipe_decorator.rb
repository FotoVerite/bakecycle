class RecipeDecorator < Draper::Decorator
  delegate_all
  decorates_association :recipe_items

  def recipe_types_select
    Recipe.recipe_types.keys.map { |key| [key.humanize(capitalize: false), key] }
  end

  def mix_size_units_select
    Recipe.mix_size_units.keys.map { |key| [key.humanize(capitalize: false), key] }
  end

  def type
    recipe_type.humanize(capitalize: false).titleize
  end

  def available_inclusions
    delete_itself_from_collection inclusionables(ingredients, recipes)
  end

  def available_ingredients
    delete_itself_from_collection inclusionables(ingredients)
  end

  def serializable_hash
    RecipeSerializer.new(object).serializable_hash
  end

  private

  def ingredients
    h.item_finder.ingredients
  end

  def recipes
    h.item_finder.recipes
  end

  def delete_itself_from_collection(collection)
    collection.delete_if do |(_name, item)|
      item == "#{object.id}-#{object.class.name}"
    end
  end

  def inclusionables(*objects)
    sort_by_name make_ids_for_select(objects)
  end

  def make_ids_for_select(collections)
    collections.flatten.map do |o|
      [o.name, "#{o.id}-#{o.class}"]
    end
  end

  def sort_by_name(items)
    items.sort do |(a_name, _), (b_name, _)|
      a_name <=> b_name
    end
  end
end
