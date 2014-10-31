FactoryGirl.define do

  #factory :folder, :class => Component do |cl|
  #  cl.name "Folder1"
  #  cl.is_root false
  #  cl.association :work_element_type#, :factory =>  :work_element_type_folder
  #end

  factory :pbs_project_element do
    name "Component"
    is_root false
    start_date Time.now

    trait :pbs_trait_folder do
      name "Folder"
    end

    trait :pbs_trait_bad do
      name "bad"
    end
  end

  factory :pbs_folder, :class => PbsProjectElement do
    name "Folder"
    is_root false
    start_date Time.now
  end

  factory :pbs_bad, :class => PbsProjectElement do |cl|
    cl.name ""
    cl.is_root false
    start_date Time.now
  end

end
