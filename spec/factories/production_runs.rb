FactoryGirl.define do
  factory :production_run do
    bakery
    date { Date.today }
  end
end
