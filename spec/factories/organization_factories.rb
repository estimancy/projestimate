#
FactoryGirl.define do

  sequence :organization_name do |n|
    "Organization_#{n}"
  end

  # Organizations
  factory :organization do
    #sequence(:name) {|n| "Organization_#{n}"}
    name { generate(:organization_name) }
    sequence(:description) {|n| "Organization number #{n}"}
    number_hours_per_day 7
    number_hours_per_month 140
    cost_per_hour 10
    limit1 10
    limit2 100
    limit3 1000
    association :currency, :factory => :euro_curreny
  end

end