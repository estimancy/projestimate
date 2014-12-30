# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :field do
    association :organization, :factory => :organization
    name "Champs"
  end
end
