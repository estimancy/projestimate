require 'spec_helper'

describe GroupsController do

  before do
    sign_in
    @connected_user = controller.current_user
    @group = FactoryGirl.create(:group)
    @project = FactoryGirl.create(:project)
    @proposed_status = FactoryGirl.build(:proposed_status)
  end

  describe 'Index' do
    it 'renders the index template' do
      get :index
      response.should render_template('index')
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end
  end

  describe 'Edit' do
    it 'renders the edit template' do
      get 'edit', {:id => @group.id}
      response.should render_template('edit')
    end
  end

  describe 'Destroy' do
    it 'renders the destroy template' do
      expect { delete 'destroy',:id => @group.id}.to change(Group, :count).by(-1)
      response.should render_template('index')
    end
  end

end