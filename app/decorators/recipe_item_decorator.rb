class RecipeItemDecorator < Draper::Decorator
  delegate_all

  def display_type
    return nil unless inclusionable
    inclusionable.send(:"#{model_name}_type").capitalize
  end

  def lead
    return 'N/A' unless model_name == 'recipe'
    inclusionable.lead_days
  end

  def model_name
    inclusionable.class.name.downcase
  end
end
