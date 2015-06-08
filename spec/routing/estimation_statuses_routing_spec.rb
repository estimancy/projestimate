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

require 'spec_helper'

RSpec.describe EstimationStatusesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/estimation_statuses").to route_to("estimation_statuses#index")
    end

    it "routes to #new" do
      expect(:get => "/estimation_statuses/new").to route_to("estimation_statuses#new")
    end

    it "routes to #show" do
      expect(:get => "/estimation_statuses/1").to route_to("estimation_statuses#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/estimation_statuses/1/edit").to route_to("estimation_statuses#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/estimation_statuses").to route_to("estimation_statuses#create")
    end

    it "routes to #update" do
      expect(:put => "/estimation_statuses/1").to route_to("estimation_statuses#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/estimation_statuses/1").to route_to("estimation_statuses#destroy", :id => "1")
    end

  end
end
