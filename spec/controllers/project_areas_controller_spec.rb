require 'spec_helper'

describe ProjectAreasController do

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

  describe 'Show' do
    it 'renders the new template' do
      @project_area = FactoryGirl.create(:project_area)
      get :show, {:id => @project_area.id}
      response.should render_template('show')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      @project_area = FactoryGirl.create(:project_area)
      get 'edit', {:id => @project_area.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @project_area = FactoryGirl.create(:project_area)
      expect { delete 'destroy',:id => @project_area.id}.to change(ProjectArea, :count).by(-1)
      response.should redirect_to project_areas_path
    end
  end

  describe 'Update' do
    it 'update project_area' do
      @project_area = FactoryGirl.create(:project_area)
      put 'update', { :id => @project_area.id }
      response.code.should eq "200"
    end
  end

  describe 'Create' do
    it 'create project_area' do
      @project_area = FactoryGirl.create(:project_area)
      post 'create', { :id => @project_area.id }
      response.code.should eq "200"
    end
  end

end