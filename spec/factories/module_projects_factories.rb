FactoryGirl.define do
  factory :module_project do
    association :pemodule, :factory => :pemodule
    association :project, :factory => :project
    association :view, :factory => :view
    position_x 0
    position_y 1
  end
end