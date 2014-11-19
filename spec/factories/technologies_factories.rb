# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :technology do
    name "Java"
    description "Java java"
    association :record_status, :factory => :defined_status, strategy: :build
  end
end
