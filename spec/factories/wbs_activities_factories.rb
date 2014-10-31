# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do

  sequence :wbs_activity_name do |n|
    "Wbs-Activity #{n}"
  end

  factory :wbs_activity do
    uuid
    name { generate(:wbs_activity_name) }
    state "defined"
    description "Wbs-Activity"
    association :record_status, :factory => :proposed_status, strategy: :build
    association :organization, :factory => :organization
  end

end
