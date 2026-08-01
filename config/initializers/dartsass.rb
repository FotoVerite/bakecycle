# frozen_string_literal: true

Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css"
}

Rails.application.config.dartsass.build_options = ["--style=expanded", "--embed-sources"] if Rails.env.development?

# @import is deprecated in Dart Sass 3.0; silenced until we migrate to @use/@forward
Rails.application.config.dartsass.build_options << "--silence-deprecation=import"

Rails.application.config.after_initialize do |app|
  app.config.assets.paths << Rails.root.join("vendor/assets/stylesheets").to_s
end
