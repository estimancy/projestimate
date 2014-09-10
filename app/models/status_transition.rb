class StatusTransition < ActiveRecord::Base
  attr_accessible :transition_from, :transition_to

  belongs_to :from_transition_status, class_name: "EstimationStatus"
  belongs_to :to_transition_status, class_name: "EstimationStatus"
end
