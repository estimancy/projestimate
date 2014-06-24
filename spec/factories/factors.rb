# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :factor do |factor|
    factor.sequence(:name) { |n| "Factor_#{n}" }
    factor.sequence(:alias) { |n| "factor#{n}" }
    factor.description "Factor Description"
    factor.factor_type "advanced"
    factor.uuid "#{UUIDTools::UUID.random_create.to_s}"
    factor.association :record_status, :factory => :defined_status, strategy: :build
  end
end
