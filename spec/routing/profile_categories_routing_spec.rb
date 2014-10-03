require 'spec_helper'

RSpec.describe ProfileCategoriesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/profile_categories").to route_to("profile_categories#index")
    end

    it "routes to #new" do
      expect(:get => "/profile_categories/new").to route_to("profile_categories#new")
    end

    it "routes to #show" do
      expect(:get => "/profile_categories/1").to route_to("profile_categories#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/profile_categories/1/edit").to route_to("profile_categories#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/profile_categories").to route_to("profile_categories#create")
    end

    it "routes to #update" do
      expect(:put => "/profile_categories/1").to route_to("profile_categories#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/profile_categories/1").to route_to("profile_categories#destroy", :id => "1")
    end

  end
end
