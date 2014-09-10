class EstimationStatus < ActiveRecord::Base
  attr_accessible :description, :status_alias, :name, :organization_id, :status_number, :status_color

  belongs_to :organization

  has_many :from_transitions,  :foreign_key => 'from_transition_status_id',
           :class_name => 'StatusTransition',
           :dependent => :destroy
  has_many :to_transition_statuses,     :through => :from_transitions


  has_many :to_transitions,   :foreign_key => 'to_transition_status_id',
           :class_name => 'StatusTransition',
           :dependent => :destroy
  has_many :from_transition_statuses, :through => :to_transitions

  #Status of Estimation Management as state machine
  has_many :projects

  #Estimations permissions on Group according to the estimation status
  has_many :estimation_status_group_roles

  validates :organization_id, presence: true
  validates :status_number, :name,  presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }

  def libelle
    "#{status_number} - #{name}"
  end

end
