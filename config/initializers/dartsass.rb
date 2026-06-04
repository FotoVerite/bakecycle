Rails.application.config.dartsass.builds = {
  "application.scss" => "application.css"
}

Rails.application.config.after_initialize do |app|
  app.config.assets.paths << Rails.root.join("vendor/assets/stylesheets").to_s
end
