FactoryGirl.define do
  factory :production_run do
    bakery
    date { Time.zone.today }
  end
end
