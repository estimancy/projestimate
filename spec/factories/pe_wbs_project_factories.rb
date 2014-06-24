FactoryGirl.define do

  #PeWbsProject
  factory :pe_wbs_project do
    sequence(:name){|n| "Pe-Wbs-Project_Root #{n}"}

    trait :wbs_product do
      wbs_type "Product"
    end

    trait :wbs_activity do
      wbs_type "Activity"
    end

  end

  factory :wbs_1, class: PeWbsProject do
    sequence(:name)   {|n| "Pe-WBS-Project_#{n}"}
    wbs_type "Product"
  end

end
