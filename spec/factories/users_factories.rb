# User

FactoryGirl.define do

  factory :admin, :class => :user do
    first_name "Administrator"
    last_name  "Projestimate"
    login_name "admin"
    email      "youremail@yourcompany.net"
    time_zone  "GMT"
    initials   "ad"
    association :auth_method, :factory => :auth_method, strategy: :build
    association :language, :factory => :language, :strategy => :build
    password   "projestimate"
    password_confirmation "projestimate"
    confirmed_at Time.now
  end

  factory :authenticated_user, :class => :user do
    first_name
    last_name
    login_name
    email
    initials
    association :auth_method, :factory => :auth_method
    association :language, :factory => :language, :strategy => :build
    password   "projestimate"
    password_confirmation "projestimate"
  end


  factory :user3, :class => :user do
    first_name #"Administrator3"
    last_name  #"Projestimate3"
    login_name #"admin3"
    email      #"admin3@yourcompany.net"
    initials   #"ad3"
    association :auth_method, :factory => :auth_method, strategy: :build
    association :language, :factory => :language, :strategy => :build
    password   "projestimate3"
    password_confirmation "projestimate3"
    confirmed_at Time.now
  end
end
