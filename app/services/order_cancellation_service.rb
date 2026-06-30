# frozen_string_literal: true

class OrderCancellationService
  Result = Struct.new(:client, :status, :message, keyword_init: true)

  STATUSES = %i[will_cancel already_cancelled needs_confirm no_order cancelled skipped error].freeze

  def initialize(bakery, client_ids, date)
    @bakery     = bakery
    @client_ids = Array(client_ids).map(&:to_i).uniq
    @date       = date
    @weekday    = date.strftime("%A").downcase
  end

  # Returns preview results without modifying any data.
  def preview
    clients.map { |client| assess(client) }
  end

  # Applies cancellations. force_client_ids are needs_confirm clients the user opted to include.
  def cancel!(force_client_ids: [])
    force_ids = Array(force_client_ids).map(&:to_i).to_set
    clients.map do |client|
      result = assess(client)
      case result.status
      when :will_cancel
        apply_cancellation(client, result)
      when :needs_confirm
        force_ids.include?(client.id) ? apply_cancellation(client, result) : skip_result(client)
      when :already_cancelled
        Result.new(client: client, status: :already_cancelled, message: result.message)
      else
        skip_result(client)
      end
    end
  end

  private

  def clients
    @clients ||= Client
      .where(bakery: @bakery, id: @client_ids)
      .where("channel IS NULL OR channel != ?", "Internal")
      .order(:name)
  end

  def assess(client)
    standing = standing_orders_for(client)

    if standing.empty?
      return Result.new(client: client, status: :no_order,
                        message: "No standing order delivers on #{@date.strftime('%A')}s.")
    end

    existing_temp = temp_order_for(client)

    if existing_temp
      if zero_order?(existing_temp)
        return Result.new(client: client, status: :already_cancelled,
                          message: "Already has a cancellation for #{@date.strftime('%b %-d')}.")
      elsif existing_temp.order_items.empty?
        return Result.new(client: client, status: :needs_confirm,
                          message: "Has an empty temporary order for #{@date.strftime('%b %-d')} " \
                                   "— confirm to rebuild it as a zero-quantity cancellation.")
      else
        return Result.new(client: client, status: :needs_confirm,
                          message: "Has a modified temporary order for #{@date.strftime('%b %-d')} " \
                                   "— confirm to zero it out.")
      end
    end

    Result.new(client: client, status: :will_cancel,
               message: "#{standing.size} active #{standing.size == 1 ? 'order' : 'orders'} will be cancelled.")
  end

  def apply_cancellation(client, _result)
    ActiveRecord::Base.transaction do
      create_zero_temp_orders(client)
      Shipment.where(bakery: @bakery, client: client, date: @date).destroy_all
    end
    Result.new(client: client, status: :cancelled, message: "Cancelled.")
  rescue StandardError => e
    Result.new(client: client, status: :error, message: e.message)
  end

  def create_zero_temp_orders(client)
    standing_orders_for(client).each do |standing|
      existing_temp = temp_order_for(client, route: standing.route)
      if existing_temp
        existing_temp.all_order_items.destroy_all
      else
        existing_temp = Order.create!(
          bakery: @bakery,
          client: client,
          route: standing.route,
          order_type: "temporary",
          start_date: @date,
          end_date: @date,
          discount: standing.discount
        )
      end
      create_zero_items(existing_temp, standing)
    end
  end

  def standing_orders_for(client)
    @standing_cache ||= {}
    @standing_cache[client.id] ||= Order
      .standing(@date)
      .where(bakery: @bakery, client: client)
      .select { |o| o.order_items.sum(@weekday).positive? }
  end

  def temp_order_for(client, route: nil)
    scope = Order.temporary(@date).where(bakery: @bakery, client: client)
    scope = scope.where(route: route) if route
    scope.includes(:all_order_items).first
  end

  def zero_order?(order)
    order.order_items.any? && order.order_items.all? { |item| item.quantity(@date).zero? }
  end

  def create_zero_items(temp_order, standing_order)
    standing_order.order_items.find_each do |item|
      temp_order.all_order_items.create!(
        product: item.product,
        monday: 0,
        tuesday: 0,
        wednesday: 0,
        thursday: 0,
        friday: 0,
        saturday: 0,
        sunday: 0
      )
    end
  end

  def skip_result(client)
    Result.new(client: client, status: :skipped, message: "Skipped.")
  end
end
