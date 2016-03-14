require "capybara-screenshot/cucumber"
Capybara::Screenshot.webkit_options = { width: 1600, height: 1200 }
Capybara::Screenshot.prune_strategy = { keep: 25 }
Capybara.save_and_open_page_path = ENV["CIRCLE_ARTIFACTS"] if ENV["CIRCLE_ARTIFACTS"]

Capybara::Screenshot.register_filename_prefix_formatter(:cucumber) do |example|
  name_of_test = example.name.tr(" ", "-").gsub(/[^\w\-]/, "")
  "screenshot_#{name_of_test}"
end
