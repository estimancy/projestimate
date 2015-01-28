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


class ModuleProject < ActiveRecord::Base
  attr_accessible  :project_id, :pemodule_id, :pemodule, :position_x, :position_y, :nb_input_attr, :nb_output_attr, :view_id, :color

  belongs_to :pemodule
  belongs_to :project, :touch => true
  belongs_to :view    # the current selected view

  belongs_to :guw_model, class_name: "Guw::GuwModel"
  belongs_to :ge_model, class_name: "Ge::GeModel"
  belongs_to :expert_judgement_instance, class_name: "ExpertJudgement::Instance"
  has_many :guw_unit_of_work_groups, class_name: "Guw::GuwUnitOfWorkGroup"
  has_many :guw_unit_of_works, class_name: "Guw::GuwUnitOfWork"

  has_many :estimation_values, :dependent => :destroy
  has_many :inputs
  has_many :input_cocomos
  has_many :factors, :through => :input_cocomos
  has_many :organization_uow_complexities, :through => :factors
  has_many :views_widgets, dependent: :delete_all

  has_and_belongs_to_many :pbs_project_elements

  has_many :first_module_projects, :class_name => 'AssociatedModuleProject', :foreign_key => 'module_project_id'
  has_many :associated_module_projects, :through => :first_module_projects

  has_many :second_module_projects, :class_name => 'AssociatedModuleProject', :foreign_key => 'associated_module_project_id'
  has_many :inverse_associated_module_projects, :through => :second_module_projects, :source => :module_project


  default_scope :order => 'position_x ASC, position_y ASC'

  amoeba do
    enable
    include_field [:estimation_values, :pbs_project_elements, :guw_unit_of_work_groups, :guw_unit_of_works, :views_widgets]

    customize(lambda { |original_module_project, new_module_project|
      new_module_project.copy_id = original_module_project.id
    })
  end

  #Return in a array previous modules project of self.
  def preceding
    mps = ModuleProject.where("position_y < #{self.position_y.to_i} AND project_id = #{self.project.id}")
  end

  #Return in a array next modules project of self.
  def following
    mps = ModuleProject.where("position_y > #{self.position_y.to_i} AND project_id = #{self.project.id}")
  end

  #Return the inputs attributes of a module_projects
  def input_attributes
    res = Array.new
    self.estimation_values.each do |est_val|
      if est_val.in_out == 'input'
        res << est_val.pe_attribute
      end
    end
    res
  end

  #Return the outputs attributes of a module_projects
  def output_attributes
    res = Array.new
    self.estimation_values.each do |est_val|
      if est_val.in_out == 'output'
        res << est_val.pe_attribute
      end
    end
    res
  end

  #Return the common attributes (previous, next)
  def self.common_attributes(mp1, mp2)
    mp1.output_attributes & mp2.input_attributes
  end

  #Return the next pemodule with link
  def next
    results = Array.new
    tmp_results = self.associated_module_projects + self.inverse_associated_module_projects
    tmp_results.each do |r|
      if self.following.map(&:id).include?(r.id)
        results << r
      end
    end
    results
  end

  #Return the previous pemodule with link
  def previous
    results = Array.new
    tmp_results = self.associated_module_projects + self.inverse_associated_module_projects
    tmp_results.each do |r|
      if self.preceding.map(&:id).include?(r.id)
        results << r
      end
    end
    results
  end

  def links
    self.associated_module_project_ids
  end

  def compatible_with(wet_alias)
    if self.pemodule.compliant_component_type.nil?
      false
    else
      self.pemodule.compliant_component_type.include?(wet_alias)
    end
  end

  def to_s
    #self.pemodule.title.humanize
    if self.pemodule.alias == Projestimate::Application::INITIALIZATION
      # nothing to show for position as the "Initialization is always on the first position"
      self.project.title #self.pemodule.title.humanize
    elsif self.pemodule.alias == "ge"
      self.ge_model.nil? ? 'Undefined model': self.ge_model.to_s
    elsif self.pemodule.alias == "guw"
      self.guw_model.nil? ? 'Undefined model': self.guw_model.to_s
    else
      "#{self.pemodule.title.humanize} (#{Projestimate::Application::ALPHABETICAL[self.position_x.to_i-1]};#{self.position_y.to_i})"
    end
  end

  def size
    module_alias = self.pemodule.alias
    if module_alias == "ge"
      previous_module_project = self.previous.first
      if previous_module_project.pemodule.alias == "expert_judgement"
        previous_module_project.expert_judgement_instance.retained_size_unit
      else
        previous_module_project.guw_model.retained_size_unit
      end
    elsif module_alias == "guw"
      self.guw_model.retained_size_unit
    elsif module_alias == "expert_judgement"
      self.expert_judgement_instance.retained_size_unit
    else
      ""
    end
  end

  #def crawl(starting_node)
  #  list = []
  #  items=[starting_node]
  #  until items.empty?
  #    item = items.shift
  #    list << item.id unless list.include?(item.id)
  #    kids = item.next.sort{ |mp1, mp2| (mp1.position_y <=> mp2.position_y) && (mp1.position_x <=> mp2.position_x)} #Get next module_project
  #    kids.each{ |kid| items << kid }
  #  end
  #  list - [starting_node.id]
  #end
end
