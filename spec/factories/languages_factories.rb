# Language

FactoryGirl.define do

  factory :language do
    sequence(:name)   {|n| "language_#{n}"}
    sequence(:locale) {|n| "locale_#{n}"}
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :en_language, :class => Language do
    name "English"
    locale "en"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :fr_language, :class => Language do
    name "Francais"
    locale "fr"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :it_language, :class => Language do
    name "Italien"
    locale "it"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :de_language, :class => Language do
    name "Deutsch"
    locale "de"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end

  factory :en_gb_language, :class => Language do
    name "English (British)"
    locale "en-gb"
    uuid
    association :record_status, :factory => :proposed_status, strategy: :build
  end


  #factory :en_language, :class => Language do
  #  sequence(:name)   {|n| "english#{n}"}
  #  sequence(:locale) {|n| "locale_english#{n}"}
  #  uuid
  #  association :record_status, :factory => :proposed_status, strategy: :build
  #end
  #
  #factory :fr_language, :class => Language do
  #  sequence(:name)   {|n| "fr#{n}"}
  #  sequence(:locale) {|n| "locale_fr#{n}"}
  #  uuid
  #  association :record_status, :factory => :proposed_status, strategy: :build
  #end

end
