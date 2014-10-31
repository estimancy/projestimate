# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :estimation_status do
    association :organization, :factory => :organization, strategy: :build
    status_number 1
    status_alias "Status_alias"
    name "Status_name"
    description "MyText"
  end
end
