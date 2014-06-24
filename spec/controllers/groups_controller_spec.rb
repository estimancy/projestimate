require 'spec_helper'

describe GroupsController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  before :each do
    @group = FactoryGirl.create(:group)
    @project = FactoryGirl.create(:project)
    @proposed_status = FactoryGirl.build(:proposed_status)
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index, :format => 'html'
      response.should render_template('index')
    end

    it 'assigns all group as @group' do
      get :index
      assigns(:group)==(@group)
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new, :format => 'html'
      response.should render_template('new')
    end
    it 'assigns a new group as @group' do
      get :new
      assigns(:group).should be_a_new_record
    end
  end

  describe 'GET edit' do
    it 'assigns the requested group as @group' do
      get :edit, {:id => @group.to_param}
      assigns(:group)==([@group])
    end
  end

  describe 'DELETE destroy' do
    #it "redirects to the admin_setting list" do
    #  delete :destroy, {:id => :admin_setting.to_param}
    #  response.should redirect_to(admin_settings_path)
    #end
    #it "destroys the requested admin_setting" do
    #  expect {
    #    delete :destroy, {:id => :admin_setting.to_param}
    #  }.to change(AdminSetting, :count).by(-1)
    #end

  end
end