require 'spec_helper'

describe AcquisitionCategoriesController do

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
      @acquisition_category = FactoryGirl.create(:acquisition_category)
      get 'edit', {:id => @acquisition_category.id}
      response.should render_template('edit')
    end
  end

end