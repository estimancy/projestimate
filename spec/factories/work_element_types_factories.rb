## Work Element Types
#
FactoryGirl.define do

  factory :work_element_type , :class => WorkElementType do
    sequence(:name) {|n| "Wet_#{n}"}
    sequence(:alias) {|n| "wet_alias#{n}"}

    association :record_status, :factory => :proposed_status, strategy: :build

    trait :wet_folder do
      sequence(:name) {|n| "Folder_#{n}"}
      sequence(:alias) {|n| "folder_alias#{n}"}
      uuid
    end

    trait :wet_link do
      sequence(:name) {|n| "Link_#{n}"}
      sequence(:alias) {|n| "link_alias#{n}"}
      uuid
    end


    trait :wet_undefined do
      sequence(:name) {|n| "Undefined_#{n}"}
      sequence(:alias) {|n| "undefined_alias#{n}"}
      uuid
    end


    trait :wet_default do
      sequence(:name) {|n| "Default_#{n}"}
      sequence(:alias) {|n| "default_alias#{n}"}
      uuid
    end


    trait :wet_developed_software do
      sequence(:name) {|n| "Developed_software_#{n}"}
      sequence(:alias) {|n| "Developed_software__alias#{n}"}
      uuid
    end
  end
end

