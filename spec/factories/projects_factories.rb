#Project

FactoryGirl.define do

  sequence :project_title do |n|
    "Project_#{n}"
  end

  sequence :project_alias do |n|
    "P#{n}"
  end

  sequence :project_description do |n|
    "Project number #{n}"
  end

  # Projects
  factory :new_project, :class => :project do |p|
    p.state 'preliminary'
    p.association :organization, :factory => :organization
    p.association :estimation_status, :factory => :estimation_status
    p.start_date Time.now
    after :build do |proj|
      proj.title = FactoryGirl.generate(:project_title)
      proj.alias = FactoryGirl.generate(:project_alias)
      proj.description = FactoryGirl.generate(:project_description)
    end
  end

  # Projects
  factory :project do |p|
    p.sequence(:title) {|n| "Project_#{n}"}
    p.sequence(:alias) {|n| "P#{n}"}
    p.sequence(:description) {|n| "Project number #{n}"}
    p.association :organization, :factory => :organization
    p.association :estimation_status, :factory => :estimation_status
    p.state 'preliminary'
    p.start_date Time.now
  end

end