require 'spec_helper'

RSpec.describe "ProfileCategories", :type => :request do
  describe "GET /profile_categories" do
    it "works! (now write some real specs)" do
      get profile_categories_path
      expect(response.status).to be(200)
    end
  end
end
