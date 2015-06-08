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

describe WorkElementTypesController do

  before :each do
    sign_in
    @user = controller.current_user
    @app_auth_method = FactoryGirl.build(:application_auth_method)

    @wet = FactoryGirl.create(:work_element_type, :wet_folder)
  end

  describe "GET 'index'" do
    it 'returns http success' do
      get 'index', :format => 'html'
      response.should render_template('index')
    end
  end

  describe 'New' do
    it 'renders the new template' do
      get :new
      #response.should render_template("new")
      expect(:get => '/work_element_types/new').to route_to(:controller => 'work_element_types', :action => 'new')
    end
  end

  describe 'Edit' do
    it 'renders the new template' do
      @wet = FactoryGirl.create(:work_element_type, :wet_folder)
      get :edit, {:id => @wet.id}
      response.should render_template('edit')
    end
  end

end
