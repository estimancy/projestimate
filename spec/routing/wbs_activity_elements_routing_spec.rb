# encoding: UTF-8
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
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

require "spec_helper"

describe WbsActivityElementsController do
  describe "routing" do

    it "routes to #index" do
      get("/wbs_activity_elements").should route_to("wbs_activity_elements#index")
    end

    it "routes to #new" do
      get("/wbs_activity_elements/new").should route_to("wbs_activity_elements#new")
    end

    it "routes to #show" do
      get("/wbs_activity_elements/1").should route_to("wbs_activity_elements#show", :id => "1")
    end

    it "routes to #edit" do
      get("/wbs_activity_elements/1/edit").should route_to("wbs_activity_elements#edit", :id => "1")
    end

    it "routes to #create" do
      post("/wbs_activity_elements").should route_to("wbs_activity_elements#create")
    end

    it "routes to #update" do
      put("/wbs_activity_elements/1").should route_to("wbs_activity_elements#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/wbs_activity_elements/1").should route_to("wbs_activity_elements#destroy", :id => "1")
    end

  end
end
