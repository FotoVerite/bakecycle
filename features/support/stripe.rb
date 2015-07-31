Around("@stripe_success") do |_scenario, block|
  require "stripe_mock"
  StripeMock.start
  block.call
  StripeMock.stop
end
