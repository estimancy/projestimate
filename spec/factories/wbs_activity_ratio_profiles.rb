# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wbs_activity_ratio_profile do
    wbs_activity_ratio_element_id 1
    organization_profile_id 1
    ratio_value 1.5
  end
end
