module Guw
  class GuwWorkUnit < ActiveRecord::Base
    belongs_to :guw_model

    validates_presence_of :name, :value

    def to_s
      name
    end
  end
end
