class RecipeItemDecorator < Draper::Decorator
  delegate_all

  def display_type
    return nil unless inclusionable
    inclusionable.send(:"#{model_name}_type").capitalize
  end

  def total_lead_display
    return 'N/A' unless inclusionable.class == Recipe
    total_lead_days
  end

  def model_name
    inclusionable.class.name.downcase
  end
end
