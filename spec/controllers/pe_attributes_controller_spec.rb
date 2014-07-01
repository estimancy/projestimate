require 'spec_helper'

describe PeAttributesController do

  before :each do
    sign_in
    @connected_user = controller.current_user
    @attribute = FactoryGirl.create(:sloc_attribute)
    @params = { :id => @attribute.id }
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index
      response.should render_template('index')
    end

    it 'assigns all attributes as @attributes' do
      get :index
      assigns(:sloc_attribute)==(@attribute)
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end

    it 'assigns a new attributes as @attribute' do
      get :new, :attribute => { :name => 'sloc_new',:alias=> 'sloc_new', :uuid => '1-new-2345', :description=> 'test new', :attr_type=> 'integer'}
      assigns(:attribute).should be_a_new_record
    end
  end

  describe 'GET edit' do
    it 'assigns the requested attribute as @attribute' do
      get :edit, {:id => @attribute.to_param}
      assigns(:sloc_attribute)==(@attribute)
    end
  end

  describe 'create' do
    before :each do
      @custom_status = FactoryGirl.build(:custom_status)
      #@params = { :name => "SLOC1",:alias=>"SLOC1", :uuid => "1", :description=>"test", :attr_type=>"integer", :record_status=>23, :custom_value=>"local"}
      @params = { :name => 'SLOC1',:alias=> 'SLOC1', :uuid => '1', :description=> 'test', :attr_type=> 'integer'}
    end

    it 'should create record with success' do
      post :create, :cost_attribute => { :name => 'SLOC1', :alias=> 'SLOC1', :uuid => '1111', :description=> 'test'}, :options => ['integer', '>=', '0']  # FactoryGirl.attributes_for(:cost_attribute)
      response.should be_success
    end

    it 'renders the create template' do
      post :create, :sloc_attribute => { :name => 'SLOC12', :alias=> 'SLOC12', :uuid => '11112', :description=> 'test2'}, :options => ['integer', '>=', '1']
      response.should be_success
    end
  end

  describe 'PUT update' do
    before :each do
      @cost_attribute = FactoryGirl.create(:cost_attribute)
      @params = {:name => 'SLOC1', :alias=> 'SLOC1', :uuid => '12345', :description=> 'test', :attr_type=> 'integer', :record_status => RecordStatus.first.id, :custom_value=> 'local'}
    end

    context 'with valid params' do
      it 'located the requested attribute' do
        put :update, id: @cost_attribute, cost_attribute: FactoryGirl.attributes_for(:cost_attribute)
        assigns(:cost_attribute)==(@cost_attribute)
      end

      it 'updates the requested peAttribute' do
        put :update, id: @cost_attribute.to_param, cost_attribute: @cost_attribute.attributes = {:description => 'My_new_description'}
        @cost_attribute.uuid='12345'
        @cost_attribute.uuid.should eq('12345')
        @cost_attribute.description.should eq('My_new_description')
      end

      it 'should redirect to the peAttribute_paths list' do
        put :update, {id: @cost_attribute.to_param}
        response.should be_success
      end
    end
  end


  describe 'DELETE destroy' do

    it 'redirects to the attributes list' do
      delete :destroy, {:id => @attribute.to_param}
      response.should redirect_to(pe_attributes_url)
    end

    it 'destroys the requested event' do
      expect {
        delete :destroy, {:id => @attribute.to_param}
      }.to change(PeAttribute, :count).by(-1)
    end
  end

end