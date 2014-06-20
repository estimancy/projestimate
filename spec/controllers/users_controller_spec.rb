require 'spec_helper'

describe UsersController, 'Creating and managing user', :type => :controller do

  before do
    sign_in
    @user = controller.current_user
  end

  describe "Authentication test" do
    it 'blocks unauthenticated user' do
      sign_in nil
      get :index
      response.should redirect_to(new_user_session_path)
    end

    it 'allows authenticated access' do
      sign_in
      get :index
      response.should be_success
    end
  end

  describe "GET 'index'" do
    it 'returns correct template' do
      get 'index'
      response.should render_template('index')
    end
  end

  describe "GET 'edit'" do
    it 'returns correct template' do
      get 'edit', :id => @user.to_param
      response.should render_template('edit')
    end
  end

  describe "GET 'new'" do
    it 'returns correct template' do
      get 'new'
      response.should render_template('new')
    end
  end

  describe "GET 'find_use_user'" do
    it 'returns correct template' do
      @params = { :user_id => @user.id, :format => 'js' }
      get 'find_use_user', @params
      response.should be_success
    end
  end

  describe "GET 'about'" do
    it 'returns http success' do
      get 'about'
      response.should be_success
    end
  end

  #describe "GET 'activate'" do
  #  it "returns http success" do
  #    @user = FactoryGirl.create(:user, :user_status => "active")
  #    @params = { :id => @user.id }
  #    get 'activate', @params
  #    response.should be_success
  #  end
  #end

  describe "GET 'display_states'" do
    it 'returns http success' do
      #@user = FactoryGirl.create(:user)
      @params = { :user_status => @user.user_status, :format => 'js' }
      get 'display_states', @params
      response.should be_success
    end
  end

end