module WizardCapybara
  def confirm_alert
    if page.driver.class == Capybara::Webkit::Driver
      page.driver.browser.accept_js_confirms
    else
      page.driver.browser.switch_to.alert.accept
    end
  end

  def send_return(node)
    # https://github.com/thoughtbot/capybara-webkit/issues/191
    raise "this feature only works in firefox" if page.driver.class == Capybara::Webkit::Driver
    node.native.send_keys(:return)
  end
end

World(WizardCapybara)
