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

#require "rails_helper"
require 'spec_helper'

RSpec.describe OrganizationProfilesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/organization_profiles").to route_to("organization_profiles#index")
    end

    it "routes to #new" do
      expect(:get => "/organization_profiles/new").to route_to("organization_profiles#new")
    end

    it "routes to #show" do
      expect(:get => "/organization_profiles/1").to route_to("organization_profiles#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/organization_profiles/1/edit").to route_to("organization_profiles#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/organization_profiles").to route_to("organization_profiles#create")
    end

    it "routes to #update" do
      expect(:put => "/organization_profiles/1").to route_to("organization_profiles#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/organization_profiles/1").to route_to("organization_profiles#destroy", :id => "1")
    end

  end
end
