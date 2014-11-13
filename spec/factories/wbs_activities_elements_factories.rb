# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence :wbs_activity_element_name do |n|
    "Wbs-Activity-Element #{n}"
  end

  factory :wbs_activity_element_root do
    uuid
    name { generate(:wbs_activity_element_name) }
    description "Wbs-Activity element root"
    is_root true
  end

end
