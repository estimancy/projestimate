class ProfileCategory < ActiveRecord::Base
  attr_accessible :name, :description, :record_status_id, :custom_value, :change_comment, :organization_id

  include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  has_many :profiles
  has_many :organization_profiles
  belongs_to :organization

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  validates :record_status, :presence => true
  validates :uuid, :presence => true, :uniqueness => {case_sensitive: false}
  validates :name, :presence => true, :uniqueness => {case_sensitive: false, :scope => :record_status_id}
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
    name
  end

end
