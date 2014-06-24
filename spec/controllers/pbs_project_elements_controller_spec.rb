require 'spec_helper'

describe PbsProjectElementsController do

  before :each do
    sign_in
    @connected_user = controller.current_user
    @work_element_type = FactoryGirl.build(:work_element_type, :wet_folder)
    @folder = FactoryGirl.create(:folder)
    @folder1 = FactoryGirl.create(:folder, :name => 'Folder11', :work_element_type => @work_element_type)
    @bad = FactoryGirl.create(:bad, :name => 'bad_name')
  end

  describe 'New' do
    #it "renders the new template" do
    #  get :new
    #  response.should render_template("new")
    #end
    #it "assigns a new work_element_type as @work_element_type" do
    #  get :new
    #  assigns(:@folder).should be_a_new_record
    #end
  end

  describe 'GET edit' do
    #it "assigns the requested work_element_type as @work_element_type" do
    #  get :edit, {:id => @folder.to_param}
    #  assigns(:folder)==(@folder)
    #end
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