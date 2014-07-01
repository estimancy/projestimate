class Profile < ActiveRecord::Base
  attr_accessible :cost_per_hour, :description, :name, :record_status, :record_status_id, :custom_value, :change_comment

  include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  validates :record_status, :presence => true
  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name, :presence => true, :uniqueness => {:scope => :record_status_id, :case_sensitive => false}
  validates :cost_per_hour, :numericality => { :allow_blank => true }
  validates :custom_value, :presence => true, :if => :is_custom?

  amoeba do
    enable

    customize(lambda { |original_record, new_record|
      new_record.reference_uuid = original_record.uuid
      new_record.reference_id = original_record.id
      new_record.record_status = RecordStatus.find_by_name('Proposed')
    })
  end

  def to_s
    self.name
  end

end
