# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :wbs_activity do
    uuid
    sequence(:name) {|n| "Wbs-Activity #{n}"}
    state "defined"
    description "Wbs-Activity"
    association :record_status, :factory => :proposed_status, strategy: :build
    association :organization, :factory => :organization
  end

end
