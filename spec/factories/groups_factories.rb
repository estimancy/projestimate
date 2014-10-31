FactoryGirl.define do

  sequence :group_name do |n|
    "group#{n}"
  end


  factory :group do
    name { generate(:group_name) } #sequence(:name) {|n| "group#{n}"}
    sequence(:description) {|n| "Group number #{n}"}
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
    for_global_permission true
  end

  factory :defined_group, :class => :group do
    name { generate(:group_name) }  #sequence(:name) {|n| "group#{n}"}
    sequence(:description) {|n| "Group number #{n}"}
    uuid
    association :record_status, :factory => :defined_status, strategy: :build
    for_global_permission true
  end

  factory :admin_group, :class => :group do
    name "Admin"
    description "ProjEstimate administrators"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
    for_global_permission true
  end

  factory :everyone_group, :class => :group do
    name "Everyone"
    description "All user accounts identified in ProjEstimate. At creation, each account is automatically added to this group. But this group stay a regular group with same behavior than all the other groups, so the administrator can remove any accounts he want from this group."
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
    for_global_permission true
  end

  factory :master_admin_group, :class => :group do
    name "MasterAdmin"
    description "Administrators of the ProjEstimate configuration"
    uuid
    association :record_status, :factory => :defined_status, strategy: :build
    for_global_permission true
  end


end