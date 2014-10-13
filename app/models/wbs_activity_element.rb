#encoding: utf-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    ======================================================================
#
# ProjEstimate, Open Source project estimation web application
# Copyright (c) 2013 Spirula (http://www.spirula.fr)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

class WbsActivityElement < ActiveRecord::Base
  attr_accessible :name, :description, :record_status_id, :custom_value, :change_comment,:is_root,:wbs_activity,:record_status,:wbs_activity_id, :dotted_id, :parent_id
  include MasterDataHelper

  has_ancestry :cache_depth => true

  belongs_to :record_status
  belongs_to :owner_of_change, :class_name => 'User', :foreign_key => 'owner_id'

  belongs_to :wbs_activity
  has_many :wbs_activity_ratio_elements, :dependent => :destroy

  has_many :wbs_project_elements

  #default_scope order("id asc")
  #default_scope order("dotted_id asc")
  scope :is_ok_for_validation, lambda { |de, re| where('record_status_id <> ? and record_status_id <> ?', de, re) }
  scope :elements_root, where(:is_root => true)

  validates :name, :presence => true, :uniqueness => {:scope => [:wbs_activity_id, :ancestry, :record_status_id], :case_sensitive => false}
  validates :uuid, :presence => true, :uniqueness => {:case_sensitive => false}
  validates :custom_value, :presence => true, :if => :is_custom?

  #Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable

    exclude_field [:wbs_activity_ratio_elements]      #TODO verify for wbs_project_elements exclusion

    customize(lambda { |original_wbs_activity_elt, new_wbs_activity_elt|

      new_wbs_activity_elt.copy_id = original_wbs_activity_elt.id
      new_wbs_activity_elt.uuid = UUIDTools::UUID.random_create.to_s
      if defined?(MASTER_DATA) and MASTER_DATA and File.exists?("#{Rails.root}/config/initializers/master_data.rb")
        new_wbs_activity_elt.record_status_id = RecordStatus.find_by_name('Proposed').id
      else
        new_wbs_activity_elt.record_status_id = RecordStatus.find_by_name('Local').id
      end
    })

    propagate
  end


  def to_s
    self.wbs_activity.name
  end

  def self.import(file, sep)
    #find localstatus
    @localstatus = RecordStatus.find_by_name('Local')

    #create wbs_activity
    @wbs_activity = WbsActivity.new(:name => "#{file.original_filename} - #{Time.now.to_s}",
                                    :state => 'draft',
                                    :record_status => @localstatus)
    @wbs_activity.save

    #create root element
    @root_element = WbsActivityElement.new(:name => @wbs_activity.name,
                                           :description => 'The root element corresponds to the wbs activity.',
                                           :dotted_id => '0',
                                           :wbs_activity => @wbs_activity,
                                           :record_status => @localstatus,
                                           :parent => nil,
                                           :is_root => true)
    @root_element.save

    sep = "#{sep.blank? ? I18n.t(:general_csv_separator) : sep}"

    #for each row save in data base
    CSV.open(file.path, 'r', :encoding => 'ISO-8859-1:utf-8', :quote_char => "\"", :row_sep => :auto, :col_sep => sep) do |csv|
      @inserts = []
      csv.each_with_index do |row, i|
        unless row.empty? or i == 0
          @inserts.push("(\"#{Time.now.utc.to_s(:db)}\",
                          \"#{Time.now.utc.to_s(:db)}\",
                          \"#{ !row[2].nil? ? row[2].gsub("\"", "\"\"") : row[2] }\",
                          \"#{ !row[0].nil? ? row[0].gsub("\"", "\"\"") : row[0] }\",
                          \"#{ !row[1].nil? ? row[1].gsub("\"", "\"\"") : row[1] }\", #{@localstatus.id}, #{@wbs_activity.id}, \"#{UUIDTools::UUID.random_create.to_s}\")")

        end
      end
    end

    ActiveRecord::Base.connection.execute("INSERT INTO wbs_activity_elements(created_at,updated_at,description,dotted_id,name,record_status_id,wbs_activity_id,uuid) VALUES  #{@inserts.join(',')}")

    elements = @wbs_activity.wbs_activity_elements
    build_ancestry(elements, @wbs_activity.id)

  end

  def self.build_ancestry(elements, activity_id)
    elements.each do |elt|
      ActiveRecord::Base.transaction do
        hierarchy = elt.dotted_id
        ancestors = []
        @root_element = WbsActivityElement.find_by_dotted_id_and_wbs_activity_id('0', activity_id)
        unless hierarchy == '0' or hierarchy.nil?
          idse = hierarchy.split(/^(.*)\.[^\.]*.$/).last
          if idse == hierarchy
            if @root_element
              elt.ancestry = @root_element.id
            end
          else
            father = WbsActivityElement.find_by_dotted_id_and_wbs_activity_id(idse, activity_id)
            unless father.nil?
              ancestors << father.ancestry
              ancestors << father.id
            end
            elt.ancestry = ancestors.join('/')
          end
          elt.save(:validate => false)
        end
      end
    end
  end

  #def self.rebuild(elements, activity_id)
  #  elements.each do |elt|
  #    ancestors = []
  #    father = WbsActivityElement.find_by_wbs_activity_id(activity_id)
  #    unless father.nil?
  #      ancestors << father.ancestry
  #      ancestors << father.id
  #    end
  #    elt.ancestry = ancestors.join('/')
  #    elt.save(:validate => false)
  #  end
  #end
end
