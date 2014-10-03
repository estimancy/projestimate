require 'spec_helper'

RSpec.describe "EstimationStatuses", :type => :request do
  describe "GET /estimation_statuses" do
    it "works! (now write some real specs)" do
      get estimation_statuses_path
      expect(response.status).to be(200)
    end
  end
end
