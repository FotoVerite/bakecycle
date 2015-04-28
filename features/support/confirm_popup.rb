module WizardCapybara
  def confirm_alert
    if page.driver.class == Capybara::Webkit::Driver
      page.driver.browser.accept_js_confirms
    else
      page.driver.browser.switch_to.alert.accept
    end
  end
end

World(WizardCapybara)
