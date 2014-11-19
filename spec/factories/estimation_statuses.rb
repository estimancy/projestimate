# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :estimation_status do
    association :organization, :factory => :organization
    status_number 1
    sequence(:status_alias) {|n| "status_alias_#{n}"}
    sequence(:name) {|n| "name_#{n}"}
    description "MyText"
  end
end
