require 'spec_helper'

describe WidgetsController do

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
      @widget = FactoryGirl.create(:widget)
      get :show, {:id => @widget.id}
      response.should render_template('show')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      @widget = FactoryGirl.create(:widget)
      get 'edit', {:id => @widget.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @widget = FactoryGirl.create(:widget)
      expect { delete 'destroy',:id => @widget.id}.to change(Widget, :count).by(-1)
      response.should render_template('index')
    end
  end

  describe 'Update' do
    it 'update project_area' do
      @widget = FactoryGirl.create(:widget)
      put 'update', { :id => @view.id }
      response.code.should eq "200"
    end
  end

  describe 'Create' do
    it 'create project_area' do
      @widget = FactoryGirl.create(:widget)
      post 'create', { :id => @view.id }
      response.code.should eq "200"
    end
  end

end