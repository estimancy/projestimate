require 'spec_helper'

describe EstimationStatusesController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  describe 'New' do
    it 'renders the new template' do
      @organization = FactoryGirl.create(:organization)
      get :new, {:organization_id => @organization.id }
      response.should render_template('new')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      @estimation_status = FactoryGirl.create(:estimation_status)
      get 'edit', {:id => @estimation_status.id }
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @organization = FactoryGirl.create(:organization)
      @estimation_status = FactoryGirl.create(:estimation_status)
      expect { delete 'destroy',:id => @estimation_status.id, :organization_id => @organization.id }.to change(EstimationStatus, :count).by(-1)
      response.should render_template('index')
    end
  end

end