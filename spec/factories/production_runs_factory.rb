FactoryBot.define do
  factory :production_run do
    bakery { create(:bakery) }
    date { Time.zone.today }
  end
end
