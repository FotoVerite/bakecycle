module ApplicationHelper
  def class_for_main_content
    return 'large-10 medium-12 small-12 columns light-grey-bg-pattern' if user_signed_in?
    'medium-6 medium-offset-3 small-10 small-offset-1 columns light-grey-bg-pattern'
  end

  def active_nav?(section)
    'active' if section == @_active_nav
  end

  def bakery_link
    return link_to('Bakeries', bakeries_path) if can? :manage, Bakery
    link_to('My Bakery', my_bakeries_path)
  end

  def full_title(page_title = nil)
    base_title = 'Bakecycle'
    return base_title if page_title.empty?
    "#{page_title} - #{base_title}"
  end
end
