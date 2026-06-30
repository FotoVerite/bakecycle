# frozen_string_literal: true

module ApplicationHelper
  LUCIDE_ICON_PATH = Rails.root.join("node_modules/lucide-static/icons")
  LUCIDE_ICON_NAME = /\A[a-z0-9-]+\z/

  def full_title(page_title = nil)
    base_title = "Bakecycle"
    return base_title if page_title.blank?

    "#{page_title} - #{base_title}".html_safe
  end

  def icon(name, label: nil, decorative: label.blank?, **options)
    safe_name = name.to_s
    raise ArgumentError, "Invalid icon name: #{name.inspect}" unless safe_name.match?(LUCIDE_ICON_NAME)

    path = LUCIDE_ICON_PATH.join("#{safe_name}.svg")
    raise ArgumentError, "Unknown Lucide icon: #{safe_name}" unless path.file?

    icon_class = options.delete(:class)
    svg = File.read(path)
    doc = Nokogiri::HTML::DocumentFragment.parse(svg)
    element = doc.at_css("svg")
    classes = ["bc-icon", icon_class].compact

    element["class"] = classes.join(" ")
    element["aria-hidden"] = "true" if decorative
    element["role"] = "img" unless decorative
    element["aria-label"] = label if label.present?

    options.each do |key, value|
      element[key.to_s.dasherize] = value
    end

    doc.to_html.html_safe
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
