FactoryGirl.define do
  factory :acquisition_category do
    description "TBD"

    trait :unknown do
      sequence(:name) { |n| "Unknown#{n}" }
      uuid
      association :record_status, :factory => :proposed_status, :strategy => :build

    end

    trait :newDevelopment do
      sequence(:name) { |n| "New_Development#{n}" }
      uuid
      association :record_status, :factory => :proposed_status, strategy: :build
    end

    trait :enhancement do
      sequence(:name) { |n| "Enhancement#{n}" }
      uuid
      association :record_status, :factory => :proposed_status, strategy: :build
    end

  end

end