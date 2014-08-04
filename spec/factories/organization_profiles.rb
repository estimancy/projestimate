# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :organization_profile do
    organization_id 1
    name "MyString"
    description "MyText"
    cost_per_hour 1.5
  end
end
