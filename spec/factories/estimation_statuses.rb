# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :estimation_status do
    organization_id 1
    status_number 1
    name "MyString"
    status_alias "mystring"
    description "MyText"
    #check_status_alias
  end
end
