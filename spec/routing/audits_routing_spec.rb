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

describe AuditsController do
  describe "routing" do

    it "routes to #index" do
      get("/audits").should route_to("audits#index")
    end

    it "routes to #new" do
      get("/audits/new").should route_to("audits#new")
    end

    it "routes to #show" do
      get("/audits/1").should route_to("audits#show", :id => "1")
    end

    it "routes to #edit" do
      get("/audits/1/edit").should route_to("audits#edit", :id => "1")
    end

    it "routes to #create" do
      post("/audits").should route_to("audits#create")
    end

    it "routes to #update" do
      put("/audits/1").should route_to("audits#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/audits/1").should route_to("audits#destroy", :id => "1")
    end

  end
end
