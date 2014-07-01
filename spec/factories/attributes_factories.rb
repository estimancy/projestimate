
#PeAttributes
FactoryGirl.define do
  factory :cost_attribute, :class => :pe_attribute  do |attr|
     attr.name "Cost"
     attr.alias "cost"
     attr.description "Cost desc"
     attr.attr_type "integer"
     attr.options []
     uuid
     association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :sloc_attribute, :class => :pe_attribute do |attr|
     attr.name "Sloc1"
     attr.alias "sloc1"
     attr.description "Attribute number 1"
     attr.attr_type "integer"
     attr.options ["integer", ">=", "10"]
     uuid
     association :record_status, :factory => :proposed_status, strategy: :build
  end
end