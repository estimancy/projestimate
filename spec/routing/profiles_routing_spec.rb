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

RSpec.describe ProfilesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/profiles").to route_to("profiles#index")
    end

    it "routes to #new" do
      expect(:get => "/profiles/new").to route_to("profiles#new")
    end

    it "routes to #show" do
      expect(:get => "/profiles/1").to route_to("profiles#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/profiles/1/edit").to route_to("profiles#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/profiles").to route_to("profiles#create")
    end

    it "routes to #update" do
      expect(:put => "/profiles/1").to route_to("profiles#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/profiles/1").to route_to("profiles#destroy", :id => "1")
    end

  end
end
