module OrdersHelper
  def new_order_return_path
    if @client
      client_path(@client)
    else
      orders_path
    end
  end
end
