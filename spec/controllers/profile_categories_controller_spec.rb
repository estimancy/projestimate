require 'spec_helper'

describe ProfileCategoriesController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  describe 'Index' do
    it 'renders the index template' do
      get :index
      response.should render_template('index')
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      @profile_category = FactoryGirl.create(:profile_category)
      get 'edit', {:id => @profile_category.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @profile_category = FactoryGirl.create(:profile_category)
      expect { delete 'destroy',:id => @profile_category.id}.to change(ProfileCategory, :count).by(-1)
      response.should redirect_to profile_categories_path
    end
  end

  describe 'New profile category' do
    it 'renders the destroy template' do
      @profile_category = FactoryGirl.create(:profile_category)
      post :new_profile_category_with_organization, { module_project_id: @profile_category.id, format: :js }
      response.code.should eq "200"
    end
  end

  describe 'New profile category' do
    it 'renders the update template' do
      @profile_category = FactoryGirl.create(:profile_category)
      put :update, id: @profile_category, profile_category: @profile_category.id
      response.should be_success
    end
  end

  describe 'New profile category' do
    it 'renders the create template' do
      @profile_category = FactoryGirl.create(:profile_category)
      post :create, id: @profile_category, profile_category: @profile_category.id
      response.should be_success
    end
  end

end