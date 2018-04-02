class BuyOrdersController < ApplicationController
  def index
    authorize Ingredient
    @ingredients = policy_scope(Ingredient).order_by_name
  end

  def create
    @buy_order = policy_scope(BuyOrder).build(buy_order_params)
    authorize @buy_order
    render json: { id: @buy_order.id, action: "create" } if @buy_order.save
  end

  def update
    @buy_order = policy_scope(BuyOrder).find(params[:id])
    authorize @buy_order
    render json: {} if @buy_order.update(buy_order_params)
  end

  private

  def buy_order_params
    params.require(:buy_order).permit(
      :amount,
      :ingredient_id,
      :vendor_id
    )
  end
end
