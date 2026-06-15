# frozen_string_literal: true

module NavigationHelper
  def render_nav?
    @_render_nav
  end

  def class_for_main_content
    return "large-10 medium-12 small-12 columns light-grey-bg-pattern" if render_nav?

    "medium-6 medium-offset-3 small-10 small-offset-1 columns light-grey-bg-pattern"
  end

  def active_nav?(*sections)
    "active show-nav" if sections.include? @_active_nav
  end

  def active_nav_group?(*sections)
    sections.include?(@_active_nav)
  end

  def navigation_pinned_actions
    return [] unless current_user

    @_navigation_pinned_actions ||= PinnedActionRegistry.entries_for(
      current_user.user_pinned_actions.ordered,
      user: current_user,
      context: self
    )
  end

  def available_pinned_actions
    return [] unless current_user

    @_available_pinned_actions ||= PinnedActionRegistry.available_for(current_user, context: self)
  end

  def pinned_action_record(action_key)
    return unless current_user

    @_pinned_action_records ||= current_user.user_pinned_actions.index_by(&:action_key)
    @_pinned_action_records[action_key.to_s]
  end
end
