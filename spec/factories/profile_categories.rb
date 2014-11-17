# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :profile_category do
    name "MyString"
    description "MyText"
    association :record_status, :factory => :proposed_status, strategy: :build
    custom_value "MyString"
    change_comment "MyText"
  end
end
