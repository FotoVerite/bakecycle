module ApplicationHelper
  def class_for_main_content
    return "large-10 medium-12 small-12 columns light-grey-bg-pattern" if user_signed_in?
    "medium-6 medium-offset-3 small-10 small-offset-1 columns light-grey-bg-pattern"
  end
end
