##########################################################################
#
# ProjEstimate, Open Source project estimation web application
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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################

# After each update of estimation value, this worker will be call to recompute estimation value for its parent component
class OrganizationDuplicateProjectWorker
  include Sidekiq::Worker

  def perform(est_model_id, new_organization_id, user_id)
    est_model = Project.find(est_model_id)
    new_organization = Organization.find(new_organization_id)
    user = User.find(user_id)

    ActiveRecord::Base.transaction do
      new_template = execute_duplication(est_model.id, new_organization.id, user_id)
      unless new_template.nil?
        new_template.is_model = est_model.is_model
        new_template.save
      end
    end

  rescue ActiveRecord::RecordNotFound
  end
end