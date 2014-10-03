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
