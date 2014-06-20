## Admin Settings
FactoryGirl.define do
   sequence :key do |n|
     "key_#{n}"
   end

   sequence :value do |n|
     "value_#{n}@email.com"
   end

   factory :admin_setting do
     uuid
     #association :record_status, :factory => :proposed_status, :strategy => :build

     trait :welcome_message do
       uuid
       key     #key "welcome_message"
       value   #value "This is my welcome message"
       association :record_status, :factory => :proposed_status, :strategy => :build
     end

     trait :notifications_email do
       uuid
       key    #key   "notifications_email"
       value  #value "AdminSpirula@email.com"
       association :record_status, :factory => :proposed_status, :strategy => :build
     end

     trait :password_min_length do
       uuid
       key    #key "password_min_length"
       value  #value "4"
       association :record_status, :factory => :proposed_status, :strategy => :build
     end

     factory :welcome_message_ad do
       welcome_message
     end

     factory :notifications_email_ad do
       notifications_email
     end

   end
end
