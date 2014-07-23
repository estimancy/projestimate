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

#PE-WBS6Project has many pbs_project_element and belongs to project
class PeWbsProject < ActiveRecord::Base
  attr_accessible :name, :project_id, :wbs_type

  has_many :pbs_project_elements, :dependent => :destroy
  has_many :wbs_project_elements, :dependent => :destroy
  has_many :wbs_activities, :through => :wbs_project_elements

  belongs_to :project, :touch => true

  scope :products_wbs, where(:wbs_type => 'Product')
  scope :activities_wbs, where(:wbs_type => 'Activity')

  #validates_presence_of :project_id  ###validates_associated :project

  #validate :project_id_exists
  #def project_id_exists
  #  begin
  #    Project.find(self.project_id)
  #  rescue ActiveRecord::RecordNotFound
  #    errors.add(:project_id, 'project_id foreign key must exist')
  #    false
  #  end
  #end

  #Enable the amoeba gem for deep copy/clone (dup with associations)
  amoeba do
    enable
    include_field [:pbs_project_elements, :wbs_project_elements]

    customize(lambda { |original_pe_wbs, new_pe_wbs|
      new_pe_wbs.name = "Copy_#{ new_pe_wbs.project.copy_number.to_i+1} of #{original_pe_wbs.name}"
    })

    propagate
  end

end
