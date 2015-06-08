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

RSpec.describe FieldsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/fields").to route_to("fields#index")
    end

    it "routes to #new" do
      expect(:get => "/fields/new").to route_to("fields#new")
    end

    it "routes to #show" do
      expect(:get => "/fields/1").to route_to("fields#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/fields/1/edit").to route_to("fields#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/fields").to route_to("fields#create")
    end

    it "routes to #update" do
      expect(:put => "/fields/1").to route_to("fields#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/fields/1").to route_to("fields#destroy", :id => "1")
    end

  end
end
