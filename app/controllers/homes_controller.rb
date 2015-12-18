#encoding: utf-8
#########################################################################
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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################
=begin
class HomesController < ApplicationController

  def update_install
    #No authorize required
    begin
      expire_fragment('about_page')

      if is_master_instance?
        flash[:warning] = I18n.t (:warning_cant_update_yourself)
        redirect_to '/about' and return
      else
        external_last_schemas_version = ExternalMasterDatabase::ExternalSchemaMigration.all.last
        # version = nil #varibale is not used!!
        #To get all version : ActiveRecord::Migrator.get_all_versions
        local_last_schema_version = ActiveRecord::Migrator.current_version  #current local migration version

        if local_last_schema_version.to_i >= external_last_schemas_version.version.to_i
          puts I18n.t (:same_schema_version)

          #Test if local data are up to date
          latest_repo_update = Home::latest_repo_update
          if params[:latest_local_update].nil? || latest_repo_update.nil? || (params[:latest_local_update].to_datetime < latest_repo_update.to_datetime)
            Home::update_master_data!
            $latest_update = Time.now #Rails.cache.write("$latest_update", Time.now)
            flash[:notice] = I18n.t (:notice_projestimate_data_successful_updated)
          else
            puts I18n.t (:repository_up_to_date)
            flash[:notice] =  I18n.t (:notice_masterdata_already_latest)
          end

        else
          flash[:warning] = I18n.t (:warning_db_schema_differ_to_masterdata)
        end
      end

      redirect_to about_url

    rescue Errno::ECONNREFUSED
      flash[:error] = I18n.t (:error_default_data_failed_update)
      redirect_to about_url and return
    rescue => e
      flash[:error] = I18n.t (:error_default_data_exception_update)
      flash[:warning] = "#{e}"
      redirect_to about_url
    end
  end
end
=end