require 'spec_helper'

describe ProjectCategoriesController do

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
      @project_category = FactoryGirl.create(:unknown_project_category)
      get 'edit', {:id => @project_category.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @project_category = FactoryGirl.create(:unknown_project_category)
      expect { delete 'destroy',:id => @project_category.id}.to change(ProjectCategory, :count).by(-1)
      response.should redirect_to project_categories_path
    end
  end

  describe 'Update' do
    it 'update project_category' do
      @project_category = FactoryGirl.create(:unknown_project_category)
      put 'update', { :id => @project_category.id }
      response.code.should eq "200"
    end
  end

  describe 'Create' do
    it 'create project_category' do
      @project_category = FactoryGirl.create(:unknown_project_category)
      post 'create', { :id => @project_category.id }
      response.code.should eq "200"
    end
  end

end