class RecipeItemSerializer < ActiveModel::Serializer
  attributes :id, :bakers_percentage, :inclusionable_id_type, :inclusionable_global_id, :inclusionable_type,
    :sort_id, :inclusionable_name, :total_lead_days, :errors

  def inclusionable_global_id
    object.inclusionable.to_global_id.to_s if object.inclusionable
  end

  def inclusionable_name
    object.inclusionable.name
  end
end
