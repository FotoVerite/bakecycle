FactoryGirl.define do
  factory :file_export do
    bakery
    trait :with_file do
      file { File.new(Rails.root.join("app/assets/images/example_logo.png")) }
    end
  end
end
