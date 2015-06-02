class RecipeItemDecorator < Draper::Decorator
  delegate_all

  def total_lead_display
    return total_lead_days if inclusionable_type == 'Recipe'
    'N/A'
  end
end
