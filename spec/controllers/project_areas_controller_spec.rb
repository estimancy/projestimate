require 'spec_helper'
describe ProjectAreasController do

  before do
    sign_in
    @connected_user = controller.current_user
  end


  before :each do
    @project_area = FactoryGirl.create(:project_area)
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end
    it 'assigns a new project_area as @project_area' do
      get :new
      assigns(:project_area).should be_a_new_record
    end
  end

  describe 'GET edit' do
    it 'assigns the requested project_area as @project_area' do
      get :edit, {:id => @project_area.to_param}
      assigns(:project_area)==(@project_area)
    end
  end

  describe 'DELETE destroy' do
    it 'redirects to the project_area list' do
      delete :destroy, {:id => @project_area.to_param}
      response.should redirect_to ('/projects_global_params#tabs-1')
    end
    it 'destroys the requested event' do
      expect {
        delete :destroy, {:id => @project_area.to_param}
      }.to change(ProjectArea, :count).by(-1)
    end

  end

  describe 'Create' do

  end

  describe 'Update' do

  end
end