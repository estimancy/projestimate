#require 'rails_helper'

RSpec.describe "Plans", :type => :request do
  describe "GET /plans" do
    it "works! (now write some real specs)" do
      get plans_path
      expect(response.status).to be(200)
    end
  end
end
