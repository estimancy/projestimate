require 'spec_helper'

describe CurrenciesController do

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
      @currency = FactoryGirl.create(:euro_curreny)
      get 'edit', {:id => @currency.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      @currency = FactoryGirl.create(:euro_curreny)
      expect { delete 'destroy',:id => @currency.id}.to change(Currency, :count).by(-1)
      response.should render_template('index')
    end
  end

end