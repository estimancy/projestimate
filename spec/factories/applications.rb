FactoryGirl.define do
  factory :application do
    name "My Application"
    association :organization, :factory => :organization, strategy: :build
  end

end
