require 'spec_helper'
  describe SearchesController do
    before :each do
      sign_in
      @connected_user = controller.current_user
    end
    describe 'GET results' do
      it 'renders the results template' do
        @params = { :search => 'sample'}
        post :results, @params
        response.should render_template('results')
      end
    end

  end