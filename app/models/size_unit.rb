class SizeUnit < ActiveRecord::Base
  include MasterDataHelper

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  validates :record_status, :presence => true
  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :name, :presence => true, :uniqueness => {:scope => :record_status_id, :case_sensitive => false}
  validates :custom_value, :presence => true, :if => :is_custom?

  attr_accessible :description, :name, :alias, :record_status_id, :custom_value, :change_comment

  belongs_to :size_unit_type

  #Search fields
  scoped_search :on => [:name, :alias, :description]

end
