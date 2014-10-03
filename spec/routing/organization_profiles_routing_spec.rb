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
