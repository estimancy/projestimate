# Read about factories at https://github.com/thoughtbot/factory_girl


#attr_accessible :cost_per_hour, :description, :name, :record_status, :record_status_id, :custom_value, :change_comment, :profile_category_id

FactoryGirl.define do
  factory :profile do
    sequence(:name) {|n| "Profile_#{n}"}
    description "MyText"
    cost_per_hour 1.5
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end
end
