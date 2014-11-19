require 'spec_helper'

describe FactorsController do

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
      @factor = FactoryGirl.create(:factor)
      get :show, {:id => @factor.id}
      response.should render_template('show')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      @factor = FactoryGirl.create(:factor)
      get 'edit', {:id => @factor.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @factor = FactoryGirl.create(:factor)
      expect { delete 'destroy',:id => @factor.id}.to change(Factor, :count).by(-1)
      response.should render_template('index')
    end
  end

end