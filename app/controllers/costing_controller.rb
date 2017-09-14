class CostingController < ApplicationController
  after_action :skip_policy_scope

  def show
    @bakery = policy_scope(Bakery).find(current_user.bakery.id)
    authorize @bakery
    @ingredients = @bakery.ingredients
  end

  def update
    @bakery = policy_scope(Bakery).find(current_user.bakery.id)
    authorize @bakery
    @bakery.update(ingredient_params)
    redirect_to costing_path
  end

  private

  def ingredient_params
    params.require(:bakery).permit(
      ingredients_attributes:
          %i[id cost current_amount vendor_id dirty]
    )
  end
end
