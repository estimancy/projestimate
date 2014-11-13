require 'spec_helper'

describe OrganizationsController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      @organization = FactoryGirl.create(:organization)
      get 'edit', {:id => @organization.id}
      response.should render_template('edit')
    end
  end

  describe 'organizationals_params' do
    it 'renders the organizationals_params template' do
      get :organizationals_params
      response.should render_template('organizationals_params')
    end
  end

end