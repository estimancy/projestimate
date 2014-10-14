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
                  :start_date, :is_model, :organization_id, :project_area_id,
                  :project_category_id, :acquisition_category_id, :platform_category_id, :parent_id

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
  belongs_to :estimation_status   #Estimation status

  has_many :events
  has_many :module_projects, :dependent => :destroy
  has_many :pemodules, :through => :module_projects
  has_many :project_securities, :dependent => :destroy

  has_many :pe_wbs_projects, :dependent => :destroy
  has_many :pbs_project_elements, :through => :pe_wbs_projects
  has_many :wbs_project_elements, :through => :pe_wbs_projects

  has_and_belongs_to_many :groups
  has_and_belongs_to_many :users

  default_scope order('title ASC, version ASC')

  serialize :included_wbs_activities, Array

  #serialize :ten_latest_projects
  #validates_presence_of :state
  validates :title, :presence => true, :uniqueness => { :scope => :version, case_sensitive: false, :message => I18n.t(:error_validation_project) }
  validates :alias, :presence => true, :uniqueness => { :scope => :version, case_sensitive: false, :message => I18n.t(:error_validation_project) }
  validates :version, :presence => true, :length => { :maximum => 64 }, :uniqueness => { :scope => :title, :scope => :alias, case_sensitive: false, :message => I18n.t(:error_validation_project) }
  validates_presence_of :organization_id, :estimation_status_id

  #Search fields
  scoped_search :on => [:title, :alias, :description, :start_date, :created_at, :updated_at]
  scoped_search :in => :organization, :on => :name
  scoped_search :in => :pbs_project_elements, :on => :name
  scoped_search :in => :wbs_project_elements, :on => [:name, :description]

  # Get project's organization statuses before each action using statuses
  #after_find  :get_project_organization_statuses

  #AASM needs
  #aasm :column => :state do # defaults to aasm_state
  #  state :preliminary, :initial => true
  #  state :in_progress
  #  state :in_review
  #  state :checkpoint
  #  state :released
  #  state :rejected
  #
  #  event :commit do #promote project
  #    transitions :to => :in_progress, :from => :preliminary
  #    transitions :to => :in_review, :from => :in_progress
  #    transitions :to => :released, :from => :in_review
  #  end
  #end


  #aasm :column => :state do   # defaults to aasm_state
  #  state :preliminary, :preliminary => true, :before_enter => :get_initial_status
  #  EstimationStatus.all.each do |status|
  #    #Define aasm states
  #    state status.status_alias.to_sym
  #  end
  #
  #  # Workflow definition
  #  event :commit do
  #    # generate workflow according to the defining workflow in organizations
  #    StatusTransition.all.each do |status_transition|
  #      to_transition_status = EstimationStatus.find(status_transition.to_transition_status_id)
  #      from_transitions = to_transition_status.from_transition_statuses.map(&:status_alias).map(&:to_sym)
  #      transitions :from => from_transitions, :to => to_transition_status.status_alias.to_sym
  #    end
  #  end
  #end

  #  Estimation status name
  def status_name
    self.estimation_status.nil? ? nil : self.estimation_status.name
  end

  # The status background color for estimations list
  def status_background_color
    self.estimation_status.nil? ? "#999999" : "##{self.estimation_status.status_color}"
  end

  # Estimation statuses possible transitions according to the project status
  def project_estimation_statuses
    if new_record? || self.estimation_status.nil? || !self.organization.estimation_statuses.include?(self.estimation_status)
      # Note: When estimation's organization changed, the status id won't be valid for the new selected organization
      #initial_status = self.organization.estimation_statuses.order(:status_number).first_or_create(organization_id: self.organization_id, status_number: 0, status_alias: 'preliminary', name: 'Préliminaire', status_color: 'F5FFFD')
      #[[initial_status.name, initial_status.id]]
      nil
    else
      estimation_statuses = self.estimation_status.to_transition_statuses.map{ |i| [i.name, i.id]}
      estimation_statuses << [self.estimation_status.name, self.estimation_status.id]
      estimation_statuses.uniq
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

  def update_project_status_comment
    # Get the project status before updating the value
    #last_estimation_status_name = self.estimation_status_id.nil? ? "" : self.estimation_status.name
    last_estimation_status_id = estimation_status_id_was
    last_estimation_status_name = last_estimation_status_id.nil? ? "" : EstimationStatus.find(last_estimation_status_id).name

    # Get changes on the project estimation_status_id after the update (to be compra with the last one)
    new_estimation_status_name = self.estimation_status_id.nil? ? "" : self.estimation_status.name
    if new_estimation_status_name !=  last_estimation_status_name
      current_comments = status_comment
      if current_comments.nil? || current_comments.blank?
        current_comments = "______________________________________________________________________\r\n \r\n"
      end
      ###new_comments = "#{I18n.l(Time.now)} : #{I18n.t(:change_estimation_status_from_to, from_status: last_estimation_status_name, to_status: new_estimation_status_name, current_user_name: ApplicationController.current_user.name)}  \r\n"
      new_comments = "#{I18n.l(Time.now)} : #{I18n.t(:change_estimation_status_from_to, from_status: last_estimation_status_name, to_status: new_estimation_status_name, current_user_name: "")}  \r\n"
      self.status_comment = current_comments.prepend(new_comments)
    end
    yield
  end

  amoeba do
    enable
    include_field [:pe_wbs_projects, :module_projects, :groups, :users, :project_securities]

    customize(lambda { |original_project, new_project|
      new_project.title = "Copy_#{ original_project.copy_number.to_i+1} of #{original_project.title}"
      new_project.alias = "Copy_#{ original_project.copy_number.to_i+1} of #{original_project.alias}"
      new_project.version = '1.0'
      new_project.description = " #{original_project.description} \n \n This project is a duplication of project \"#{original_project.title} (#{original_project.alias}) - #{original_project.version}\" "
      new_project.copy_number = 0
      new_project.is_model = false
      original_project.copy_number = original_project.copy_number.to_i+1
    })

    propagate
  end

  def self.encoding
    ['Big5', 'CP874', 'CP932', 'CP949', 'gb18030', 'ISO-8859-1', 'ISO-8859-13', 'ISO-8859-15', 'ISO-8859-2', 'ISO-8859-8', 'ISO-8859-9', 'UTF-8', 'Windows-874']
  end

  #Return possible states of project based on the project's organization statuses workflow
  def states
    #self.aasm.states(:permissible => true).map(&:name)
    Project.aasm.states_for_select
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