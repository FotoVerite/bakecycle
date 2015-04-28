Capybara.javascript_driver = :webkit

Before('@javascript') do
  if Capybara.javascript_driver == :webkit
    page.driver.block_unknown_urls
    # page.driver.allow_url 'http://thinkwhyfirst?'
  end
end
