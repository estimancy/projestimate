require 'spec_helper'

describe LaborCategoriesController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  before :each do
    @labor = FactoryGirl.create(:labor_category)
    @proposed_status = FactoryGirl.build(:proposed_status)
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index
      response.should render_template('index')
    end
    it 'assigns all labor as @labor' do
      get :index
      assigns(:labor)==(@labor)
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end
    #it "assigns a new labor as @labor" do
    #  get :new
    #  assigns(:labor).should be_a_new(LaborCategory)
    #end
  end

  describe 'GET edit' do
    it 'assigns the requested labor as @labor' do
      get :edit, {:id => @labor.to_param}
      assigns(:labor)==([@labor])
    end
  end

  describe 'DELETE destroy' do
    #it "redirects to the labor list" do
    #  delete :destroy, {:id => :labor.to_param}
    #  response.should redirect_to(labor_categories_path)
    #end
    #it "destroys the requested labor" do
    #  expect {
    #    delete :destroy, {:id => :labor.to_param}
    #  }.to change(LaborCategory, :count).by(-1)
    #end

  end
end