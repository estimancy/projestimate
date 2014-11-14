# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :views_widget do
    view_id 1
    widget_id 1
    name "MyString"
    module_project_id 1
    pe_attribute_id 1
    pbs_project_element_id 1
    icon_class "MyString"
    color "MyString"
    show_min_max false
  end
end
