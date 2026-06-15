# frozen_string_literal: true

class PinnedActionRegistry
  Entry = Data.define(:key, :label, :description, :context, :icon, :path)

  ACTIONS = YAML.load_file(Rails.root.join("config/pinned_actions.yml")).transform_values do |definition|
    definition.symbolize_keys.merge(
      route: definition.fetch("route").to_sym,
      permission: definition.fetch("permission").to_sym
    )
  end.freeze

  class << self
    # rubocop:disable Rails/Delegate -- `delegate` can't resolve the ACTIONS constant from inside `class << self`
    def keys
      ACTIONS.keys
    end
    # rubocop:enable Rails/Delegate

    def registered?(key)
      ACTIONS.key?(key.to_s)
    end

    def available?(key, user)
      definition = ACTIONS[key.to_s]
      definition && send(definition.fetch(:permission), user)
    end

    def available_for(user, context:)
      ACTIONS.filter_map do |key, definition|
        build_entry(key, definition, context) if available?(key, user)
      end
    end

    def entries_for(pins, user:, context:)
      pins.filter_map do |pin|
        definition = ACTIONS[pin.action_key]
        build_entry(pin.action_key, definition, context) if definition && available?(pin.action_key, user)
      end
    end

    private

    def build_entry(key, definition, context)
      Entry.new(
        key: key,
        label: definition.fetch(:label),
        description: definition.fetch(:description),
        context: definition.fetch(:context),
        icon: definition.fetch(:icon),
        path: context.public_send(definition.fetch(:route))
      )
    end

    def bakery_member?(user)
      user.bakery.present?
    end

    def client_read?(user)
      bakery_member?(user) && (user.admin? || %w[read manage].include?(user.client_permission))
    end

    def client_manage?(user)
      bakery_member?(user) && (user.admin? || user.client_permission == "manage")
    end

    def shipping_read?(user)
      bakery_member?(user) && (user.admin? || %w[read manage].include?(user.shipping_permission))
    end

    def shipping_manage?(user)
      bakery_member?(user) && (user.admin? || user.shipping_permission == "manage")
    end

    def production_read?(user)
      bakery_member?(user) && (user.admin? || %w[read manage].include?(user.production_permission))
    end

    def product_read?(user)
      bakery_member?(user) && (user.admin? || %w[read manage].include?(user.product_permission))
    end
  end
end
