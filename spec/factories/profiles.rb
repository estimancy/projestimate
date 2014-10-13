# Read about factories at https://github.com/thoughtbot/factory_girl


#attr_accessible :cost_per_hour, :description, :name, :record_status, :record_status_id, :custom_value, :change_comment, :profile_category_id

FactoryGirl.define do
  factory :profile do
    name "MyString"
    description "MyText"
    cost_per_hour 1.5
    record_status_id 1
    record_status 1
  end
end
