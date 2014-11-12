require 'spec_helper'

describe ModuleProjectsController do

  before :each do
    sign_in
    @connected_user = controller.current_user
    @module_project = FactoryGirl.create(:module_project)
  end

  describe 'Pbs Element Matrix' do
    it 'renders the index template' do
      get :pbs_element_matrix, {project_id: @project}
      response.should render_template('pbs_element_matrix')
    end
  end

  describe 'Module Project Matrix' do
    it 'renders the index template' do
      get :module_projects_matrix, {project_id: @project}
      response.should render_template('module_projects_matrix')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      @module_project = FactoryGirl.create(:module_project)
      get 'edit', {:id => @module_project.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      #@module_project = FactoryGirl.create(:module_project)
      expect { delete 'destroy',:id => @module_project.id}.to change(ModuleProject, :count).by(-1)
      response.should render_template('index')
    end
  end

end