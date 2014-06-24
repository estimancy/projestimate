require 'rubygems'
require 'uuidtools'

FactoryGirl.define do

  #sequence to generate UUID on test records
  sequence :uuid do |n|
    "#{UUIDTools::UUID.random_create.to_s}"
  end

  sequence :first_name do |n|
    "Admin_#{n}"
  end

  sequence :last_name do |n|
    "Projestimate_#{n}"
  end

  sequence :login_name do |n|
    "login_name_#{n}"
  end

  sequence :email do |n|
    "email_#{n}@yahoo.fr"
  end

  sequence :initials do |n|
    "Ad_#{n}"
  end

  sequence :password_reset_token do |n|
    "#{SecureRandom.urlsafe_base64}"
  end

  factory :user do
    first_name
    last_name
    login_name
    email
    initials
    #time_zone  "GMT"
    association :auth_method, :factory => :auth_method
    user_status 'pending'
    association :language, :factory => :en_language, strategy: :build
    password 'projestimate1'
    password_confirmation 'projestimate1'
    password_reset_token
    confirmed_at Time.now
  end

  factory :master_admin do

  end

  factory :logged_in_admin, :class => User do
    first_name
    last_name
    login_name
    email
    initials
    association :auth_method, :factory => :auth_method
    time_zone 'GMT'
    user_status 'pending'
    association :language, :factory => :language
    password 'projestimate'
    password_confirmation 'projestimate'
    password_reset_token
    confirmed_at Time.now
  end

  factory :ProjectCategory do
    name 'Project1'
    description 'en'
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  # Components
  factory :pbs_project_element_first, :class => PbsProjectElement do
    name 'Root component'
    is_root true
    pe_wbs_project
  end

  factory :pe_attribute, :class => PeAttribute do |attr|
     attr.name 'attr'
     attr.alias 'attr'
     attr.description 'Attr'
     attr.attr_type 'Integer'
     attr.options []
     uuid
     association :record_status, :factory => :proposed_status, strategy: :build
  end
end