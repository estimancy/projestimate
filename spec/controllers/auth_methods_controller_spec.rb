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

describe AuthMethodsController do

  before :each do
    sign_in
    @connected_user = controller.current_user
    @default_auth_method = FactoryGirl.create(:auth_method)
    proposed_status = FactoryGirl.build(:proposed_status)
    @another_auth_method = AuthMethod.new(:name => 'LDAP', :server_name => 'example.com', :port => 636, :base_dn => 'something', :uuid => '124563', :record_status => proposed_status)
  end

  describe 'GET index' do
    it 'renders the index template' do
      get :index
      response.should render_template(:index)
    end

    it 'assigns all default_auth_method as @default_auth_method' do
      get :index
      assigns(:default_auth_method)==(@default_auth_method)
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      response.should be_success
    end
  end

  describe 'PUT update' do
    before :each do
      @auth_method = FactoryGirl.create(:auth_method)
    end
    context 'with valid params' do
      it 'updates the requested acquisition_category' do
        #@params = { :id=> @default_auth_method.id,:server_name=>"Not necessary", :port=>0, :base_dn=>"Not necessary", :record_status_id=>23, :uuid=>1, :name=>"Not necessary", :custom_value=>"local"}
        put :update, id: @auth_method, auth_method: FactoryGirl.attributes_for(:auth_method)
        response.should be_success
      end
    end
  end

  describe 'create' do
    it 'renders the create template' do
      @params = { :server_name=> 'Not necessary', :port=>0, :base_dn=> 'Not necessary', :record_status_id=>23, :uuid=>1, :name=> 'Not necessary', :custom_value=> 'local'}
      post :create, @params
      response.should be_success
    end
    #it "renders the create template" do
    #  @params = { :name => "Breton", :locale => "br" }
    #  post :create, @params
    #  response.should redirect_to projects_global_params_path(:anchor => "tabs-4")
    #end
  end

  describe 'GET edit' do
    it 'assigns the requested default_auth_method as @default_auth_method' do
      get :edit, {:id => @default_auth_method.id}
      assigns(:default_auth_method)==([@default_auth_method])
    end
  end

  describe 'DELETE destroy' do

    #it "destroys the requested @@default_auth_method" do
    #    @params = { :id => @default_auth_method.id }
    #    delete :destroy, @params
    #    response.should be_success
    #end
    #it "redirects to the @auth_method list" do
    #  @params = { :id => @default_auth_method.id }
    #  delete :destroy, @params
    #  response.should redirect_to(auth_methods_path)
    #end

  end
end