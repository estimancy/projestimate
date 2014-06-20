require 'spec_helper'
describe PemodulesController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  describe 'GET index' do
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

end