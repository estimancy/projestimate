# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :profile_category do
    name "MyString"
    description "MyText"
    record_status_id 1
    custom_value "MyString"
    change_comment "MyText"
  end
end
