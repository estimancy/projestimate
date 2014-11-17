require 'spec_helper'

describe TechnologiesController do

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
      @technology = FactoryGirl.create(:technology)
      get :show, {:id => @technology.id}
      response.should render_template('show')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      @technology = FactoryGirl.create(:technology)
      get 'edit', {:id => @technology.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @technology = FactoryGirl.create(:technology)
      expect { delete 'destroy',:id => @technology.id}.to change(Technology, :count).by(-1)
      response.should redirect_to
    end
  end

  describe 'Update' do
    it 'update technology' do
      @technology = FactoryGirl.create(:technology)
      put 'update', { :id => @technology.id }
      response.code.should eq "200"
    end
  end

  describe 'Create' do
    it 'create technology' do
      @technology = FactoryGirl.create(:technology)
      post 'create', { :id => @technology.id }
      response.code.should eq "200"
    end
  end

end