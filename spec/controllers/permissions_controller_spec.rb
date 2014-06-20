require 'spec_helper'
describe PermissionsController do

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
end