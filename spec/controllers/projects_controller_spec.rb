require 'spec_helper'

describe ProjectsController do

  before :each do
    sign_in
    @connected_user = controller.current_user

    @project = FactoryGirl.create(:project, :title => 'Project11', :alias => 'P11')
    @user = FactoryGirl.build(:user)

    @user1 = User.new(:last_name => 'Projestimate', :first_name => 'Administrator', :login_name => 'admin1', :email => 'youremail1@yourcompany.net', :user_status => 'active', :auth_type => AuthMethod.first.id, :password => 'test', :password_confirmation => 'test')
    #@project1 = Project.new(:title => 'Project1', :description => 'project number 1', :alias => 'P1', :state => 'preliminary')
    @project1 = FactoryGirl.build(:project)
    @project_security_1 = ProjectSecurity.new(:project_id => @project1.id, :user_id => @user1.id)
    @project_security = ProjectSecurity.new(:project_id => @project.id, :user_id => @user1.id)
  end

  before :all do
    @user2 = User.new(:last_name => 'Projestimate', :first_name => 'Administrator', :login_name => 'admin2', :email => 'youremail2@yourcompany.net', :user_status => 'active', :auth_type => 6, :password => 'test', :password_confirmation => 'test')
    @project2 = Project.new(:title => 'Project1', :description => 'project number 1', :alias => 'P1', :state => 'preliminary')
    @project2_security = ProjectSecurity.new(:project_id => @project2.id, :user_id => @user2.id)
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index
      #response.should render_template("index")
      expect(:get => '/projects').to route_to(:controller => 'projects', :action => 'index')
    end

    it 'assigns all projects as @projects' do
      get :index
      assigns(:project)==(@project1)
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      expect(:get => '/projects/new').to route_to(:controller => 'projects', :action => 'new')
    end

    it 'assigns a new attributes as @attribute' do
      get :new, :project => {:title => 'New Project', :description => 'project number new', :alias => 'Pnew', :state => 'preliminary'}
      assigns(:project).should be_a_new_record
    end
  end

  describe 'POST Create' do
    it 'renders the create template' do
      post :create
      #response.should render_template("new")
      expect(:post => '/projects').to route_to(:controller => 'projects', :action => 'create')
    end
  end

  describe 'GET edit' do
    #@defined_status = FactoryGirl.build(:defined_status)
    #it "assigns the requested project as @project" do
    #  get :edit, {:id => @project.to_param}
    #  assigns(:project)==(@project)
    #end
  end

  describe 'PUT update' do
    before :each do
      @new_project = FactoryGirl.create(:project, :title => 'New project', :alias => 'NewP')
    end

    context 'with valid params' do
      #it "located the requested project" do
      #  put :update, id: @new_project, project: FactoryGirl.attributes_for(:project)
      #  assigns(:project)==(@new_project)
      #end
      #
      #it "updates the requested peAttribute" do
      #  put :update, id: @new_project.to_param, project: @new_project.attributes = {:title => "12345", :alias => "My_new_Alias"}
      #  @new_project.title.should eq("12345")
      #  @new_project.alias.should eq("My_new_Alias")
      #end
      #
      #it "should redirect to the peAttribute_paths list" do
      #  put :update, {id: @new_project.to_param}
      #  response.should be_success
      #end
    end
  end

  #describe "DELETE destroy" do
  #
  #  it "redirects to the project list" do
  #    delete :destroy, {:id => @attribute.to_param}
  #    response.should redirect_to(session[:return_to])
  #  end
  #end


end