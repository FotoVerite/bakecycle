
class Api::V1::OrdersController < ActionController::Base
  use JwtAuth

  ATTRIBUTES = [
                :id,
                :client_id,
                :note,
                :start_date,
                :end_date,
                :total_lead_days,
                :order_type
              ]

  def show
    client_id = request.env.values_at :client_id
    order = Client.find(client_id[0])
      .orders
      .includes(:order_items)
      .select(ATTRIBUTES)
      .where(order_type: "standing")
      .order_by_active.limit(1).first
      .to_json(include: {
        order_items: {
          methods: [:product_information]
        }
      }
    )
    products =  Product.where(bakery_id: 1).available if params[:product_info] == 'true'

    products_array = products.map do |product|
      {
        id: product.id,
        name: product.name,
        base_price: product.base_price,
        total_lead_days: product.total_lead_days,
        price_varient_info: product.price_varient_info(client_id)
    }
    end.sort_by {|h| h[:name]}
    render json: { success: true, 
      order: order,
      products: products_array.to_json
    }
  end

  def update
    client_id = request.env.values_at :client_id
    client = Client.find(client_id[0])
    if client.update_attributes(client_params)
      render json: { success: true, client: Client.select(ATTRIBUTES).find(client_id[0])}
    else
      render json: {success: false, client: Client.select(ATTRIBUTES).find(client_id[0])}
    end
  end

  private

  def client_params
    params.require(:client).permit(
     ATTRIBUTES
    )
  end

end
