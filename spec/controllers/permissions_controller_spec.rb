require 'spec_helper'

describe PermissionsController do

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
      @permission = FactoryGirl.create(:permission)
      get 'edit', {:id => @permission.id}
      response.should render_template('edit')
    end
  end

  describe 'Globals Permissions' do
    it 'set rights' do
      get 'globals_permissions'
      response.should render_template('globals_permissions')
    end
  end

  describe 'Update' do
    it 'set rights' do
      @permission = FactoryGirl.create(:permission)
      put 'update', { :id => @permission.id }
      response.code.should eq "200"
    end
  end

  describe 'Create' do
    it 'set rights' do
      @permission = FactoryGirl.create(:permission)
      post 'create', { :id => @permission.id }
      response.code.should eq "200"
    end
  end

  describe 'Set rights' do
    it 'set rights' do
      post 'set_rights'
      response.code.should eq "200"
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @permission = FactoryGirl.create(:permission)
      expect { delete 'destroy',:id => @permission.id}.to change(Permission, :count).by(-1)
      response.should render_template('index')
    end
  end

end