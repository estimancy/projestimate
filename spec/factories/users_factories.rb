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
    user_status "active"
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
    user_status "active"
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
    user_status "active"
    association :language, :factory => :language, :strategy => :build
    password   "projestimate3"
    password_confirmation "projestimate3"
    confirmed_at Time.now
  end


#  factory :user do
#
#    #factory :admin_user do
#      first_name    "Administrator"
#      last_name     "Projestimate"
#      login_name    "admin1"
#      password      "projestimate"
#      password_confirmation "projestimate"
#      initials      "ad"
#      email         "youremail1@yourcompany.net"
#      auth_method
#      user_status   "active"
#      #association   :language
#    #end
#  end
#
#  factory :auth_method do
#    name  "Application"
#    server_name "Not necessary"
#    port 0
#    base_dn "Not necessary"
#    certificate  "false"
#  end
#
end
