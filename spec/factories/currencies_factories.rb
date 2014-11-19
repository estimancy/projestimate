# Currencies

FactoryGirl.define do

  factory :euro_curreny, :class => Currency do |cu|
    sequence(:name) {|n| "EUR#{n}"}
    sequence(:alias) {|n| "eur#{n}"}
    sequence(:description) {|n| "description#{n}"}
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  #factory :dollar_curreny, :class => Currency do |cu|
  #  cu.name   "US Dollar"
  #  cu.alias  "USD"
  #  cu.description  "TBD"
  #  uuid
  #  association :record_status, :factory => :proposed_status, strategy: :build
  #end
  #
  #factory :pound_curreny, :class => Currency do |cu|
  #  cu.name   "British Pound"
  #  cu.alias  "GBP"
  #  cu.description  "TBD"
  #  uuid
  #  association :record_status, :factory => :proposed_status, strategy: :build
  #end

end
