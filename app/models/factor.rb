class Factor < ActiveRecord::Base
  include MasterDataHelper #Module master data management (UUID generation, deep clone, ...)

  attr_accessible :alias, :description, :name, :state, :factor_type, :record_status_id

  has_many :organization_uow_complexities, :dependent => :destroy


  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  validates :record_status, :presence => true
  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name, :presence => true, :uniqueness => {:scope => :record_status_id, :case_sensitive => false}
  validates :custom_value, :presence => true, :if => :is_custom?

  amoeba do
    enable
    exclude_field [:users]

    customize(lambda { |original_record, new_record|
      new_record.reference_uuid = original_record.uuid
      new_record.reference_id = original_record.id
      new_record.record_status = RecordStatus.find_by_name('Proposed')
    })
  end

  #Override
  def to_s
    self.name
  end
end
