#require 'rails_helper'
require 'spec_helper'

RSpec.describe "Profiles", :type => :request do
  describe "GET /profiles" do
    it "works! (now write some real specs)" do
      get profiles_path
      expect(response.status).to be(200)
    end
  end
end
