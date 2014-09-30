module Guw
  class GuwModel < ActiveRecord::Base
    def to_s
      name
    end
  end
end
