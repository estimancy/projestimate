# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :view do
    name "2013-03-19 14:28:31"
    description "2013-03-19 14:28:31"
    association :organization, :factory => :organization, strategy: :build
  end
end
