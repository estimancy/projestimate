
FactoryGirl.define do

  factory :unknown_project_category, :class => ProjectCategory do
    name "Unknown"
    description  "TBD"
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :multimedia_project_category, :class => ProjectCategory do
    name "Mulimedia"
    description  "TBD"
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :network_management_project_category, :class => ProjectCategory do
    name  "Network Management"
    description  "TBD"
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :office_automation_project_category, :class => ProjectCategory do
    name  "Office Automation"
    description  "TBD"
    association :record_status, :factory => :proposed_status, strategy: :build
  end

end

