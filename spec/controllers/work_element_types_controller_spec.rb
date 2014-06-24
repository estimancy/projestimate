require 'spec_helper'

describe WorkElementTypesController do

  before :each do
    sign_in
    @user = controller.current_user
    @app_auth_method = FactoryGirl.build(:application_auth_method)

    @wet = FactoryGirl.create(:work_element_type, :wet_folder)
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get 'index', :format => 'html'
      response.should render_template('index')
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      #response.should render_template("new")
      expect(:get => '/work_element_types/new').to route_to(:controller => 'work_element_types', :action => 'new')
    end
  end

  describe 'Edit' do
    it 'renders the new template' do
      @wet = FactoryGirl.create(:work_element_type, :wet_folder)
      get :edit, {:id => @wet.id}
      response.should render_template('edit')
    end
  end

end
