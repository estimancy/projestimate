require 'spec_helper'

describe ProjectsController do

  before :each do
    sign_in
    @connected_user = controller.current_user

    @project = FactoryGirl.create(:project)
    @pe_wbs_product = FactoryGirl.create(:pe_wbs_project, :wbs_product, project: @project )
    @pe_wbs_activity = FactoryGirl.create(:pe_wbs_project, :wbs_activity, project: @project)

    @pbs_root = FactoryGirl.create(:pbs_folder, is_root: true, pe_wbs_project: @pe_wbs_product)
    @wbs_root = FactoryGirl.create(:wbs_project_element, is_root: true, pe_wbs_project: @pe_wbs_activity)

    @user = FactoryGirl.build(:user)

    @user1 = User.new(:last_name => 'Projestimate', :first_name => 'Administrator', :login_name => 'admin1', :email => 'youremail1@yourcompany.net', :auth_type => AuthMethod.first.id, :password => 'test', :password_confirmation => 'test')
    @project_security_1 = ProjectSecurity.new(:project_id => @project.id, :user_id => @user1.id)
    @project_security = ProjectSecurity.new(:project_id => @project.id, :user_id => @user1.id)
  end

  before :all do
    @user2 = User.new(:last_name => 'Projestimate', :first_name => 'Administrator', :login_name => 'admin2', :email => 'youremail2@yourcompany.net', :auth_type => 6, :password => 'test', :password_confirmation => 'test')
    #@project2 = Project.new(:title => 'Project1', :description => 'project number 1', :alias => 'P1', :state => 'preliminary')
    @project2 = FactoryGirl.create(:project)
    @project2_security = ProjectSecurity.new(:project_id => @project2.id, :user_id => @user2.id)
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index
      response.should render_template("index")
      expect(:get => '/projects').to route_to(:controller => 'projects', :action => 'index')
    end

    it 'assigns all projects as @projects' do
      get :index
      assigns(:project)==(@project)
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
      response.should render_template("new")
      expect(:post => '/projects').to route_to(:controller => 'projects', :action => 'create')
    end
  end

  describe 'GET edit' do
    it "assigns the requested project as @project" do
      get :edit, {:id => @project.id}
      assigns(:project)==(@project)
    end
  end

  describe 'PUT update' do

    context 'with valid params' do
      it "located the requested project" do
        put :update, id: @project, project: FactoryGirl.attributes_for(:project)
        assigns(:project)==(@project)
      end

      it "updates the requested project's peAttribute" do
        put :update, id: @project.id, project: @project.attributes = {:title => "Project new title", :alias => "My_new_Alias"}
        @project.title.should eq("Project new title")
        @project.alias.should eq("My_new_Alias")
      end

      it "should redirect to the peAttribute_paths list" do
        put :update, { id: @project.id }
        response.should redirect_to(session[:return_to])
      end
    end
  end

  describe "DELETE destroy" do
    it "redirects to the project list" do
      delete :destroy, { :id => @project.id }

      response.should render_template('projects/confirm_deletion')
    end
  end

end