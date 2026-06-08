# frozen_string_literal: true

module Api
  module V1
    class OrdersController < ActionController::Base
      use JwtAuth

      ATTRIBUTES = %i[
        id
        client_id
        note
        start_date
        end_date
        total_lead_days
        order_type
      ].freeze

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
          })
        products = params[:product_info] == "true" ? Product.where(bakery_id: 1).available : []

        products_array = products.map do |product|
          {
            id: product.id,
            name: product.name,
            base_price: product.base_price,
            total_lead_days: product.total_lead_days,
            price_varient_info: product.price_varient_info(client_id)
          }
        end
        products_array.sort_by! { |h| h[:name] }
        render json: { success: true,
                       order: order,
                       products: products_array.to_json }
      end

      def update
        client_id = request.env.values_at :client_id
        order = Client.find(client_id[0])
          .orders
          .where(order_type: "standing")
          .order_by_active.limit(1).first
        if order&.update(order_params)
          render json: { success: true, order: order.as_json(only: ATTRIBUTES) }
        else
          render json: { success: false, order: order&.as_json(only: ATTRIBUTES) }
        end
      end

      private

      def order_params
        params.require(:order).permit(ATTRIBUTES - %i[id client_id])
      end
    end
  end
end
