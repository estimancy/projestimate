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

class Project < ActiveRecord::Base
  attr_accessible :title, :description, :version, :alias, :state, :estimation_status_id, :status_comment,
                  :start_date, :is_model, :organization_id, :project_area_id, :project_category_id,
                  :acquisition_category_id, :platform_category_id, :parent_id

  attr_accessor :product_name, :project_organization_statuses

  include ActionView::Helpers
  include ActiveModel::Dirty

  has_ancestry  # For the Ancestry gem

  belongs_to :organization
  belongs_to :project_area
  belongs_to :acquisition_category
  belongs_to :platform_category
  belongs_to :project_category
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :estimation_status

  has_many :module_projects, :dependent => :destroy
  has_many :pemodules, :through => :module_projects
  has_many :project_securities, :dependent => :destroy

  has_many :pe_wbs_projects, :dependent => :destroy
  has_many :pbs_project_elements, :through => :pe_wbs_projects
  has_many :wbs_project_elements, :through => :pe_wbs_projects

  default_scope order('title ASC, version ASC')

  serialize :included_wbs_activities, Array

  validates :title, :presence => true, :uniqueness => { :scope => :version, case_sensitive: false, :message => I18n.t(:error_validation_project) }
  validates :alias, :presence => true, :uniqueness => { :scope => :version, case_sensitive: false, :message => I18n.t(:error_validation_project) }
  validates :version, :presence => true, :length => { :maximum => 64 }, :uniqueness => { :scope => :title, :scope => :alias, case_sensitive: false, :message => I18n.t(:error_validation_project) }
  validates_presence_of :organization_id, :estimation_status_id

  #Search fields
  scoped_search :on => [:title, :alias, :description, :start_date, :created_at, :updated_at]
  scoped_search :in => :organization, :on => :name
  scoped_search :in => :pbs_project_elements, :on => :name
  scoped_search :in => :wbs_project_elements, :on => [:name, :description]

  amoeba do
    enable
    ####include_field [:pe_wbs_projects, :module_projects, :project_securities]
    include_association [:pe_wbs_projects, :module_projects, :project_securities]

    customize(lambda { |original_project, new_project|
      new_copy_number = original_project.copy_number.to_i+1
      new_project.title = "#{original_project.title}(#{new_copy_number})" ###"Copy_#{ original_project.copy_number.to_i+1} of #{original_project.title}"
      new_project.alias = "#{original_project.alias}(#{new_copy_number})" ###"Copy_#{ original_project.copy_number.to_i+1} of #{original_project.alias}"
      new_project.version = '1.0'
      new_project.description = " #{original_project.description} \n \n This project is a duplication of project \"#{original_project.title} (#{original_project.alias}) - #{original_project.version}\" "
      new_project.copy_number = 0
      new_project.is_model = false
      original_project.copy_number = new_copy_number
    })

    propagate
  end

  #Get the project's WBS-Activity
  def project_wbs_activity
    project_wbs_activity = nil
    # Project pe_wbs_activity
    pe_wbs_activity = self.pe_wbs_projects.activities_wbs.first
    # Get the wbs_project_element which contain the wbs_activity_ratio
    project_wbs_project_elt_root = pe_wbs_activity.wbs_project_elements.elements_root.first
    # If we manage more than one wbs_activity per project, this will be depend on the wbs_project_element ancestry(witch has the wbs_activity_ratio)
    wbs_project_elt_with_ratio = project_wbs_project_elt_root.children.where('is_added_wbs_root = ?', true).first
    if wbs_project_elt_with_ratio
      project_wbs_activity = wbs_project_elt_with_ratio.wbs_activity  # Select only Wbs-Activities affected to current project's organization
    end
    project_wbs_activity
  end

  #  Estimation status name
  def status_name
    self.estimation_status.nil? ? nil : self.estimation_status.name
  end

  # The status background color for estimations list
  def status_background_color
    self.estimation_status.nil? ? "#999999" : "##{self.estimation_status.status_color}"
  end

  # Estimation statuses possible transitions according to the project status
  def project_estimation_statuses(organization=nil)
    if new_record? || self.estimation_status.nil? #|| !self.organization.estimation_statuses.include?(self.estimation_status)
      # For new record
      if organization.nil?
        nil
      else
        initial_status = organization.estimation_statuses.order(:status_number).first_or_create(organization_id: organization.id, status_number: 0, status_alias: 'preliminary', name: 'Préliminaire', status_color: 'F5FFFD')
        [[initial_status.name, initial_status.id]]
      end
      #nil
    else
      estimation_statuses = self.estimation_status.to_transition_statuses
      estimation_statuses << self.estimation_status
      estimation_statuses.uniq.sort{|s1, s2| s1 <=> s2 }
    end
  end

  def get_project_organization_statuses
    self.project_organization_statuses = self.organization.estimation_statuses

    initial_state = EstimationStatus.order(:status_number).first

    # Define existing estimation_status as aasm_state
    self.project_organization_statuses.all.each do |status|
      #aasm.state status.status_alias.to_sym
      aasm  do # defaults to aasm_state
        state status.status_alias.to_sym

        # Workflow definition for the commit event   # Redesign the 'commit' event AASM workflow with the estimation_statuses workflow
        event :commit do
          # generate workflow according to the defining workflow in organizations
          StatusTransition.all.each do |status_transition|
            to_transition_status = EstimationStatus.find(status_transition.to_transition_status_id)
            from_transitions = to_transition_status.from_transition_statuses.map(&:status_alias).map(&:to_sym)

            transitions :from => from_transitions, :to => to_transition_status.status_alias.to_sym
          end
        end
      end
    end
  end

  def self.encoding
    ['Big5', 'CP874', 'CP932', 'CP949', 'gb18030', 'ISO-8859-1', 'ISO-8859-13', 'ISO-8859-15', 'ISO-8859-2', 'ISO-8859-8', 'ISO-8859-9', 'UTF-8', 'Windows-874']
  end

  #Return the root pbs_project_element of the pe-wbs-project and consequently of the project.
  def root_component
    self.pe_wbs_projects.products_wbs.first.pbs_project_elements.select { |i| i.is_root = true }.first unless self.pe_wbs_projects.products_wbs.first.nil?
  end

  def wbs_project_element_root
    self.pe_wbs_projects.activities_wbs.first.wbs_project_elements.select { |i| i.is_root = true }.first unless self.pe_wbs_projects.activities_wbs.first.nil?
  end

  #Override
  def to_s
    "#{title} - #{version}"
  end

  # Change project status according to the project's organization estimation statuses
  def commit_status
    #Get the project's current status
    current_status_number = self.estimation_status.status_number
    # According to the status transitions map, only possible statuses will consider
    possible_statuses = self.project_estimation_statuses.map(&:status_number).sort #self.estimation_status.to_transition_statuses.map(&:status_number).uniq.sort
    current_status_index = possible_statuses.index(current_status_number)
    # By default the first possible status is candidate
    next_status_number = possible_statuses.first
    # If the current status is not the last element of the array, the next status is next element after the current status
    if current_status_number != possible_statuses.last
      next_status_number = possible_statuses[current_status_index+1]
    end

    begin
      # Get the next status
      next_status = self.organization.estimation_statuses.find_by_status_number(next_status_number)
      self.update_attribute(:estimation_status_id, next_status.id)
    rescue
    end
  end

  #Return project value
  def project_value(attr)
    self.send(attr.project_value.gsub('_id', ''))
  end

  def self.table_search(search)
    if search
      where('title LIKE ? or alias LIKE ? or state LIKE ?', "%#{search}%", "%#{search}%", "%#{search}%")
    else
      scoped
    end
  end

  #Estimation plan o project is locked or not?
  def locked?
    (self.is_locked.nil? or self.is_locked == true) ? true : false
  end

  def in_frozen_status?
    (self.state.in?(%w(rejected released checkpoint))) ? true : false
  end


  def self.json_tree(nodes)
    nodes.map do |node, sub_nodes|
      #{:id => node.id.to_s, :name => node.title, :title => node.title, :version => node.version, :data => {}, :children => json_tree(sub_nodes).compact}
      #{id: node.id.to_s, name: node.title, title: node.title, version: node.version, data: {}, children: json_tree(sub_nodes).compact}
      {:id => node.id.to_s, :name => node.version, :data => {:title => node.title, :version => node.version, :state => node.status_name.to_s}, :children => json_tree(sub_nodes).compact}
    end
  end

end