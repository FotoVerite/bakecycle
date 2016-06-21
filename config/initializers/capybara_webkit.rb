if defined?(Capybara::Webkit)
  Capybara::Webkit.configure do |config|
    # config.allow_url "http://thinkwhyfirst?"
    config.block_unknown_urls
    config.skip_image_loading
  end
end
