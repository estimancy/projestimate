# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :status_transition do
    transition_from 1
    transition_to 1
  end
end
