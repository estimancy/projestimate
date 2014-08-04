# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :profile do
    name "MyString"
    description "MyText"
    cost_per_hour 1.5
  end
end
