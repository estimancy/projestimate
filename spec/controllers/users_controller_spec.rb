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

describe UsersController, 'Creating and managing user', :type => :controller do

  before do
    sign_in
    @user = controller.current_user
  end

  describe "Authorization tests" do
    it 'should have at least one group' do

    end
  end

  describe "Authentication test" do
    it 'blocks unauthenticated user' do
      sign_in nil
      get :index
      response.should redirect_to(new_user_session_path)
    end

    it 'allows authenticated access' do
      sign_in
      get :index
      response.should be_success
    end
  end

  describe "GET 'index'" do
    it 'returns correct template' do
      get 'index'
      response.should render_template('index')
    end
  end

  describe "GET 'edit'" do
    it 'returns correct template' do
      get 'edit', :id => @user.to_param
      response.should render_template('edit')
    end
  end

  describe "GET 'new'" do
    it 'returns correct template' do
      get 'new'
      response.should render_template('new')
    end
  end

  describe "GET 'find_use_user'" do
    it 'returns correct template' do
      @params = { :user_id => @user.id, :format => 'js' }
      get 'find_use_user', @params
      response.should be_success
    end
  end

  describe "GET 'about'" do
    it 'returns http success' do
      get 'about'
      response.should be_success
    end
  end

end