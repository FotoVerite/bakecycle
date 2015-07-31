class RecipeItemSerializer < ActiveModel::Serializer
  attributes :id, :bakers_percentage, :inclusionable_id_type, :inclusionable_global_id, :inclusionable_type,
    :sort_id, :inclusionable_name, :total_lead_days, :errors, :inclusionable_type_display

  def inclusionable_global_id
    object.inclusionable.to_global_id.to_s if object.inclusionable
  end

  def inclusionable_name
    object.inclusionable.name
  end

  def inclusionable_type_display
    if object.inclusionable_type == "Ingredient"
      object.inclusionable.ingredient_type.capitalize
    else
      object.inclusionable_type.capitalize
    end
  end
end
