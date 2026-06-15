# frozen_string_literal: true

module ApplicationHelper
  def full_title(page_title = nil)
    base_title = "Bakecycle"
    return base_title if page_title.blank?

    "#{page_title} - #{base_title}".html_safe
  end

  def job_queue_table
    render partial: "dashboard/job_queue_table"
  end

  def funny_loading_message
    LoadingMessages.sample
  end

  def loading_indicator
    render "loading_indicator"
  end
end
