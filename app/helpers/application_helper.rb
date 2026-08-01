# frozen_string_literal: true

module ApplicationHelper
  LUCIDE_ICON_PATH = Rails.root.join("node_modules/lucide-static/icons")
  LUCIDE_ICON_NAME = /\A[a-z0-9-]+\z/

  def full_title(page_title = nil)
    base_title = "Bakecycle"
    return base_title if page_title.blank?

    "#{page_title} - #{base_title}".html_safe
  end

  # Standard "Actions" column icon-link used in every responsive table
  # (documented in CLAUDE.md: --edit/--create/--document/--fulfillment/
  # --financial/--destructive). `variant` is required -- an omitted variant
  # used to silently render an uncolored circle instead of a semantic tint.
  # link_data/span_data pass through to link_to/the span for call sites that
  # need turbo_frame, turbo_stream, turbo_method+turbo_confirm, or a Stimulus
  # controller/target (e.g. sync-download's icon-swap target). link_options
  # covers plain link_to options like target: "_blank".
  def action_icon(path, icon_name:, label:, variant:, link_data: {}, span_data: {}, link_options: {})
    link_to path, **link_options, data: link_data do
      content_tag(:span, icon(icon_name),
                  class: "table-action-icon table-action-icon--#{variant} icon-link-tooltip",
                  "aria-label": label,
                  data: span_data)
    end
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

    # Serialize just the <svg> node, not the whole parsed fragment -- lucide-static's
    # source files include a leading license comment as a sibling node, which
    # doc.to_html would otherwise leak into the rendered DOM on every icon use.
    element.to_html.html_safe
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

  # Gates browser RUM (app/assets/javascripts/otel_web.js) on the same env vars
  # the backend's OpenTelemetry SDK uses, so local dev without OTEL configured
  # doesn't spend every pageload posting spans to a proxy with nowhere to send them.
  def otel_frontend_enabled?
    ENV["OTEL_EXPORTER_OTLP_TRACES_ENDPOINT"].present? || ENV["OTEL_EXPORTER_OTLP_ENDPOINT"].present?
  end
end
