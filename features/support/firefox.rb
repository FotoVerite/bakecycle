Around('@firefox') do |_scenario, block|
  raise 'The selenium-webdriver gem needs to be loaded' unless defined?(Selenium::WebDriver)
  previous = Capybara.javascript_driver
  Capybara.javascript_driver = :selenium
  block.call
  Capybara.javascript_driver = previous
end
