# encoding: UTF-8
#############################################################################
#
# Estimancy, Open Source project estimation web application
# Copyright (c) 2014 Estimancy (http://www.estimancy.com)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#############################################################################

require 'spec_helper'

describe LanguagesController do

  before :each do
    sign_in
    @connected_user =  controller.current_user

    @language = FactoryGirl.create(:language)
    @params = { :id => @language.id }
  end

  describe 'GET index' do
    #before do
    #  group_permission_1 = double(Permission, :object_associated => "Group", :name => "manage")
    #  group_permission_2 = double(Permission, :object_associated => "Group", :name => "manage_master_groups")
    #  group_permission_3 = double(Permission, :object_associated => "Language", :name => "manage")
    #  group_permission_4 = double(Permission, :object_associated => "Language", :name => "create_and_edit_language")
    #  group_permission_5 = double(Permission, :object_associated => "User", :name => "access_admin_menu")
    #  group_permission_6 = double(Permission, :object_associated => "User", :name => "manage")
    #
    #  user_groups = double(Group, :for_global_permission => true, :permissions => [group_permission_1, group_permission_2, group_permission_3, group_permission_4, group_permission_5, group_permission_6])
    #  user_language = double(Language, :name => "English", :locale => "en")
    #
    #  @user = double(User, :language => user_language, :groups => [user_groups], :group_for_global_permissions => [user_groups])
    #
    #  #@user.stub(:groups).and_return(user_groups)   ###controller.stub(:current_site).and_return(site)
    #
    #  should_authorize(:index, Language)
    #
    #  User.stub(:all).and_return(@user)
    #  Language.stub(:all).and_return(@language)
    #
    #  request.cookies[:auth_token] = @user.auth_token
    #
    #  controller.stub(:current_user).and_return(@user)
    #end

    it 'should be successful' do
      get 'index'
      response.should be_success
    end

    it 'renders the index template' do
      get :index
      expect(:get => '/languages').to route_to(:controller => 'languages', :action => 'index')
    end

    it 'render index if have read ability on project' do
      get :index
      assert_template :index
  end

  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should render_template('new')
    end
  end

  describe 'edit' do
    it 'renders the new template' do
      @user = User.first

      get :edit, @params
      response.should render_template('edit')
    end
  end

  describe 'create' do
    it 'renders the create template' do
      @params = FactoryGirl.attributes_for(:language, :name => 'Breton', :locale => 'br')
      post :create, :factor => @params
      response.should be_success
    end

    it "redirect after the create" do
      #@params = { :name => "Breton", :locale => "br" }
      #@params = FactoryGirl.attributes_for(:language, :name => "Breton", :locale => "br")
      #post :create, :language => @params
      #response.should redirect_to(languages_path)
    end
  end

  describe 'PUT update' do
    before :each do
      @new_language = FactoryGirl.create(:language)
    end

    context 'with valid params' do
      it 'updates the requested record_status' do
        put :update, id: @new_language, language: FactoryGirl.attributes_for(:language)
        response.should be_success
      end
    end
  end

  describe 'DELETE destroy' do
    it "destroys the requested record_status" do
        @params = { :id => @language.id }
        delete :destroy, @params
        response.should redirect_to(languages_path)
    end

    it 'redirects to the record_statuses list' do
      @params = { :id => @language.id }

      delete :destroy, @params
      response.should redirect_to(languages_url)
      #response.should be_success
    end
  end
end