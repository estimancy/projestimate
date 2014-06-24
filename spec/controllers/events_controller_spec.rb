require 'spec_helper'

describe EventsController do

  before do
    sign_in
    @connected_user = controller.current_user
  end

  before :each do
    @event = FactoryGirl.create(:event)
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index
      response.should render_template('index')
    end

    it 'assigns all attributes as @attributes' do
      get :index
      assigns(:event)==(@event)
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end

    it 'assigns a new event as @event' do
      get :new
      assigns(:event).should be_a_new_record
    end
  end

  describe 'GET edit' do
    it 'assigns the requested attribute as @attribute' do
      get :edit, {:id => @event.to_param}
      assigns(:event)==([@event])
    end
  end

  #describe "DELETE destroy" do
  #  it "redirects to the event list" do
  #    delete :destroy, {:id => @event.to_param}
  #    response.should redirect_to(events_path)
  #  end
  #  it "destroys the requested event" do
  #        expect {
  #          delete :destroy, {:id => @event.to_param}
  #        }.to change(Event, :count).by(-1)
  #  end
  #end
end