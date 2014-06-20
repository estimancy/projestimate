require 'spec_helper'

describe OrganizationsController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end
  end

end