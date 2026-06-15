# frozen_string_literal: true

class PinnedActionsController < ApplicationController
  before_action :set_pin, only: %i[destroy]
  after_action :skip_policy_scope, only: %i[create destroy reorder]

  def index
    authorize UserPinnedAction
    @pinned_actions = policy_scope(UserPinnedAction).ordered
    @available_actions = PinnedActionRegistry.available_for(current_user, context: view_context)
  end

  def create
    authorize UserPinnedAction
    action_key = params.require(:action_key).to_s

    unless PinnedActionRegistry.available?(action_key, current_user)
      return redirect_back fallback_location: pinned_actions_path,
                           alert: "That action is not available to pin."
    end

    pin = current_user.user_pinned_actions.build(action_key: action_key, position: next_position)

    if pin.save
      redirect_to return_path, notice: "#{pin_label(action_key)} pinned."
    else
      redirect_to return_path, alert: pin.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize @pin
    label = pin_label(@pin.action_key)
    @pin.destroy!
    normalize_positions
    redirect_to return_path, notice: "#{label} unpinned."
  end

  def reorder
    authorize UserPinnedAction, :create?

    ids = Array(params[:ordered_ids]).map(&:to_i)
    pins = current_user.user_pinned_actions.where(id: ids).index_by(&:id)
    return head :unprocessable_entity unless pins.keys.sort == ids.sort

    UserPinnedAction.transaction do
      ids.each_with_index { |id, position| pins[id].update_column(:position, position) }
    end

    head :ok
  end

  private

  def set_pin
    @pin = policy_scope(UserPinnedAction).find(params[:id])
  end

  def normalize_positions
    current_user.user_pinned_actions.ordered.each_with_index do |pin, position|
      pin.update_column(:position, position)
    end
  end

  def next_position
    current_user.user_pinned_actions.maximum(:position).to_i + 1
  end

  def pin_label(action_key)
    PinnedActionRegistry::ACTIONS.dig(action_key, :label) || "Action"
  end

  def return_path
    url_from(params[:return_to]) || pinned_actions_path
  end
end
