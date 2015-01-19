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


class SearchesController < ApplicationController

  #Display search result
  # Search with the "scoped_search " gem
  def results
    #No authorize required since everyone can search
    if params[:search].class == Array
      classes = params[:search][:classes].map { |i| String::keep_clean_space(i).camelcase.constantize }
    else
      classes = [Project, ProjectArea, PlatformCategory, ProjectCategory, AcquisitionCategory, WbsActivity, Pemodule, PeAttribute, WorkElementType,
                 Organization, User, Group, OrganizationProfile, OrganizationUowComplexity, Field, ProjectField, EstimationStatus, OrganizationTechnology,
                 UnitOfWork, Factor, SizeUnit, SizeUnitType, Subcontractor, Guw::GuwModel]
    end

    # Get the current_user Organization
    #user_organization = current_user.organization

    @results = Array.new
    @result_count = Hash.new
    test = params[:search_action]
    test2 = params[:appendedDropdownButton]
    if params[:search] != "" && params[:search] != nil

      classes.each do |class_name|
        query = params[:search]
        res = []

        begin
          case params[:search_option]

            when "search_all_words"
              res = class_name.search_for(query)

            when "search_any_words"
              res = class_name.search_for(query.gsub(" ", " OR "))

            when "search_phrase"
              res = class_name.search_for(" \"#{query}\" ")

            when "search_query"
              res = class_name.search_for(query)

            else
              res = class_name.search_for(query)
          end
        rescue
          next
        end

        @result_count[class_name] = res.size
        @results <<  res
      end
    end

    @results = @results.flatten
  end
end
